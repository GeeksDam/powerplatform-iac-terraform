
terraform {
    required_version = ">= 1.6"
    required_providers {
        powerplatform = {
            source  = "microsoft/power-platform"
            version = "~> 3.9.1"
        }
        local = {
            source  = "hashicorp/local"
            version = "~> 2.4"
        }
    }
}

# Read shared terraform.tfvars file directly  
locals {
  shared_vars = {
    for line in split("\n", file("../shared/terraform.tfvars")) :
    trimspace(split("=", line)[0]) => trimspace(replace(replace(split("=", line)[1], "\"", ""), " ", ""))
    if length(split("=", line)) == 2 && !startswith(trimspace(line), "#") && trimspace(line) != ""
  }
}

# Provider configuration using shared values (same as shared/providers.tf)
provider "powerplatform" {
    use_cli       = false
    client_id     = local.shared_vars.client_id
    client_secret = local.shared_vars.client_secret
    tenant_id     = local.shared_vars.tenant_id
}

# This data source will use the provider configured above
data "powerplatform_environments" "all_envs" {
}

# Format environment data for CSV output in the current directory
locals {
  csv_header = "Environment ID,Display Name,Environment Type,Location,Azure Region,Dataverse URL,Currency Code,Language Code\n"
  
  csv_data = join("", [
    for env in data.powerplatform_environments.all_envs.environments : 
    "${env.id},\"${env.display_name}\",${env.environment_type},${env.location},${env.azure_region},\"${try(env.dataverse.url, "N/A")}\",${try(env.dataverse.currency_code, "N/A")},${try(env.dataverse.language_code, "N/A")}\n"
  ])
  
  csv_content = "${local.csv_header}${local.csv_data}"
}

# Write environment inventory to CSV file
resource "local_file" "env_inventory_csv" {
  content              = local.csv_content
  filename             = "${path.module}/environment_inventory_${local.shared_vars.tenant_id}.csv"
  file_permission      = "0644"
  directory_permission = "0755"
}

# Output the CSV file location
output "csv_file_location" {
  description = "Location of the generated environment inventory CSV file"
  value       = local_file.env_inventory_csv.filename
  sensitive   = true
}

# Output environment count
output "environment_count" {
  description = "Total number of environments found"
  value       = length(data.powerplatform_environments.all_envs.environments)
}
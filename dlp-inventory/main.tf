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

# Provider configuration using shared values
provider "powerplatform" {
    use_cli       = false
    client_id     = local.shared_vars.client_id
    client_secret = local.shared_vars.client_secret
    tenant_id     = local.shared_vars.tenant_id
}

# Data source to get all DLP policies
data "powerplatform_data_loss_prevention_policies" "all" {}

# Create CSV content with DLP policies and their assigned environments
locals {
  tenant_id = local.shared_vars.tenant_id
  
  # CSV header
  csv_header = "policy_display_name,policy_id,default_connectors_classification,environment_type,environments\n"
  
  # CSV rows - one per policy
  csv_rows = [
    for policy in data.powerplatform_data_loss_prevention_policies.all.policies :
    "${policy.display_name},${policy.id},${policy.default_connectors_classification},${policy.environment_type},\"${join(";", [for env in policy.environments : env])}\""
  ]
  
  # Combine header and rows
  csv_content = join("\n", concat([local.csv_header], local.csv_rows))
}

# Write CSV file to current directory
resource "local_file" "dlp_inventory" {
  filename = "${path.module}/dlp_policies_${local.tenant_id}.csv"
  content  = local.csv_content
  
  # Overwrite if file exists
  file_permission = "0644"
}

# Outputs
output "dlp_policy_count" {
  description = "Total number of DLP policies found"
  value       = length(data.powerplatform_data_loss_prevention_policies.all.policies)
}

output "csv_file_location" {
  description = "Location of the generated CSV file"
  value       = local_file.dlp_inventory.filename
}

output "dlp_policies_summary" {
  description = "Summary of DLP policies"
  value = {
    for policy in data.powerplatform_data_loss_prevention_policies.all.policies :
    policy.display_name => {
      id                   = policy.id
      environment_type     = policy.environment_type
      environment_count    = length(policy.environments)
      default_classification = policy.default_connectors_classification
    }
  }
}

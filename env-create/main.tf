terraform {
    required_version = ">= 1.6"
    required_providers {
        powerplatform = {
            source  = "microsoft/power-platform"
            version = "~> 3.9.1"
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

# Read CSV file and parse environments
locals {
  # Read CSV file
  csv_content = file("${path.module}/environments.csv")
  
  # Split into lines and remove header
  csv_lines = [for line in split("\n", local.csv_content) : line if line != "" && !startswith(line, "display_name") && !startswith(line, "#")]
  
  # Parse CSV into map of environments
  environments = {
    for idx, line in local.csv_lines :
    split(",", line)[0] => {
      display_name      = split(",", line)[0]
      environment_type  = split(",", line)[1]
      location         = split(",", line)[2]
      currency_code    = split(",", line)[3]
      language_code    = tonumber(split(",", line)[4])
      security_group_id = length(split(",", line)) > 5 && trimspace(split(",", line)[5]) != "" ? trimspace(split(",", line)[5]) : null
      enable_dataverse = length(split(",", line)) > 6 && trimspace(split(",", line)[6]) != "" ? tobool(lower(trimspace(split(",", line)[6]))) : true
      description      = length(split(",", line)) > 7 ? split(",", line)[7] : ""
    }
  }
  
  # Separate environments with and without Dataverse
  environments_with_dataverse = {
    for key, env in local.environments :
    key => env if env.enable_dataverse
  }
  
  environments_without_dataverse = {
    for key, env in local.environments :
    key => env if !env.enable_dataverse
  }
}

# Create Power Platform environments WITH Dataverse from CSV
resource "powerplatform_environment" "csv_environments_with_dataverse" {
  for_each = local.environments_with_dataverse
  
  display_name     = each.value.display_name
  location         = each.value.location
  environment_type = each.value.environment_type
  description      = each.value.description
  
  dataverse = merge(
    {
      language_code = each.value.language_code
      currency_code = each.value.currency_code
    },
    each.value.security_group_id != null ? { security_group_id = each.value.security_group_id } : {}
  )

  lifecycle {
    prevent_destroy = false
  }
}

# Create Power Platform environments WITHOUT Dataverse from CSV
resource "powerplatform_environment" "csv_environments_without_dataverse" {
  for_each = local.environments_without_dataverse
  
  display_name     = each.value.display_name
  location         = each.value.location
  environment_type = each.value.environment_type
  description      = each.value.description

  lifecycle {
    prevent_destroy = false
  }
}

# Outputs for created environments
output "created_environments" {
  description = "Map of created Power Platform environments"
  value = merge(
    {
      for key, env in powerplatform_environment.csv_environments_with_dataverse :
      key => {
        id                = env.id
        display_name      = env.display_name
        environment_type  = env.environment_type
        location          = env.location
        url               = env.dataverse.url
        security_group_id = env.dataverse.security_group_id
        has_dataverse     = true
      }
    },
    {
      for key, env in powerplatform_environment.csv_environments_without_dataverse :
      key => {
        id                = env.id
        display_name      = env.display_name
        environment_type  = env.environment_type
        location          = env.location
        url               = null
        security_group_id = null
        has_dataverse     = false
      }
    }
  )
}

output "environment_count" {
  description = "Total number of environments created"
  value       = length(powerplatform_environment.csv_environments_with_dataverse) + length(powerplatform_environment.csv_environments_without_dataverse)
}

output "environment_urls" {
  description = "List of environment URLs for environments with Dataverse"
  value = {
    for key, env in powerplatform_environment.csv_environments_with_dataverse :
    env.display_name => env.dataverse.url
  }
}

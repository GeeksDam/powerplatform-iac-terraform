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

# Read CSV file for DLP policies
locals {
  # Read policies CSV file
  policies_csv_content = file("${path.module}/dlp-policies.csv")
  
  # Split into lines and remove header and comments
  policies_csv_lines = [
    for line in split("\n", local.policies_csv_content) : 
    line if line != "" && !startswith(line, "policy_name") && !startswith(line, "#")
  ]
  
  # Parse CSV into map of policies
  policy_definitions = {
    for idx, line in local.policies_csv_lines :
    split(",", line)[0] => {
      policy_name              = split(",", line)[0]
      default_classification   = split(",", line)[1]
      environment_type         = split(",", line)[2]
      environments             = length(split(",", line)) > 3 && trimspace(split(",", line)[3]) != "" ? split(";", trimspace(split(",", line)[3])) : []
    }
  }
}

# Read CSV file for connector assignments
locals {
  # Read connectors CSV file
  connectors_csv_content = file("${path.module}/dlp-connectors.csv")
  
  # Split into lines and remove header and comments
  connectors_csv_lines = [
    for line in split("\n", local.connectors_csv_content) : 
    line if line != "" && !startswith(line, "policy_name") && !startswith(line, "#")
  ]
  
  # Parse CSV into list of connector assignments
  connector_assignments = [
    for idx, line in local.connectors_csv_lines :
    {
      policy_name    = split(",", line)[0]
      connector_id   = split(",", line)[1]
      classification = split(",", line)[2]
    }
  ]
  
  # Group connectors by policy and classification
  connectors_by_policy = {
    for policy_name, policy in local.policy_definitions :
    policy_name => {
      business = [
        for assignment in local.connector_assignments :
        assignment.connector_id if assignment.policy_name == policy_name && assignment.classification == "Business"
      ]
      non_business = [
        for assignment in local.connector_assignments :
        assignment.connector_id if assignment.policy_name == policy_name && assignment.classification == "NonBusiness"
      ]
      blocked = [
        for assignment in local.connector_assignments :
        assignment.connector_id if assignment.policy_name == policy_name && assignment.classification == "Blocked"
      ]
    }
  }
}

# Create DLP policies from CSV
resource "powerplatform_data_loss_prevention_policy" "csv_policies" {
  for_each = local.policy_definitions
  
  display_name                    = each.value.policy_name
  default_connectors_classification = each.value.default_classification
  environment_type                = each.value.environment_type
  
  # Only include environments if they are specified
  environments = length(each.value.environments) > 0 ? each.value.environments : []
  
  # Business data group
  business_connectors = length(local.connectors_by_policy[each.key].business) > 0 ? [
    for connector_id in local.connectors_by_policy[each.key].business : {
      id = connector_id
    }
  ] : []
  
  # Non-business data group
  non_business_connectors = length(local.connectors_by_policy[each.key].non_business) > 0 ? [
    for connector_id in local.connectors_by_policy[each.key].non_business : {
      id = connector_id
    }
  ] : []
  
  # Blocked connectors
  blocked_connectors = length(local.connectors_by_policy[each.key].blocked) > 0 ? [
    for connector_id in local.connectors_by_policy[each.key].blocked : {
      id = connector_id
    }
  ] : []
  
  # Custom connectors patterns (empty by default)
  custom_connectors_patterns = []

  lifecycle {
    prevent_destroy = false
  }
}

# Outputs for created DLP policies
output "created_dlp_policies" {
  description = "Map of created DLP policies"
  value = {
    for key, policy in powerplatform_data_loss_prevention_policy.csv_policies :
    key => {
      id                   = policy.id
      display_name         = policy.display_name
      environment_type     = policy.environment_type
      default_classification = policy.default_connectors_classification
      environment_count    = length(policy.environments)
      business_connector_count = length(policy.business_connectors)
      non_business_connector_count = length(policy.non_business_connectors)
      blocked_connector_count = length(policy.blocked_connectors)
    }
  }
}

output "dlp_policy_count" {
  description = "Total number of DLP policies created"
  value       = length(powerplatform_data_loss_prevention_policy.csv_policies)
}

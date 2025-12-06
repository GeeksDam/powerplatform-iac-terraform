# Outputs for sharing configuration with other Terraform configs
output "client_id" {
  value     = var.client_id
  sensitive = true
}

output "client_secret" {
  value     = var.client_secret
  sensitive = true
}

output "tenant_id" {
  value     = var.tenant_id
  sensitive = true
}
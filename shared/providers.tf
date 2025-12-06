terraform{
    required_version = ">= 1.6"
    required_providers {
      powerplatform = {
        source = "microsoft/power-platform"
        version = "~> 3.0"

      }
    }
}
provider "powerplatform" {
    use_cli = false
    # Configuration options
    # Authentication done via service principal
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
  }
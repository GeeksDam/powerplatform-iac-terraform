# Variable for storing the client ID
variable "client_id" {
  type = string
  sensitive = true
}
# Variable for storing the client secret
variable "client_secret" {
  type = string
  sensitive = true
}
# Variable for storing the tenant ID
variable "tenant_id" {
  type = string
  sensitive = true
}
# Mutable variable for environment configuration
variable "environments" {
    type = map(object({
        display_name = string
        environment_type = string
        location = string
        currenncy_code = string
        language_code = string
        purpose = string

    }))
    default = {}
    
}
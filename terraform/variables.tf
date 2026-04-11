variable "virtual_environment_endpoint" {
  description = "The endpoint for Proxmox VE API"
  type = string
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox VE API"
  type = string
  sensitive = true 
}

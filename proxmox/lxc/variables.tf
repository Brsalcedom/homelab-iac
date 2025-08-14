variable "pm_api_token_id" {
  description = "PPM API Token ID"
  type        = string
  sensitive   = true
}

variable "pm_api_token_secret" {
  description = "PPM API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  sensitive   = true
}

variable "ssh_authorized_key" {
  description = "SSH authorized key"
  type        = string
}
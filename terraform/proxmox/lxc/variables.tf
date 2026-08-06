variable "ssh_authorized_keys" {
  description = "SSH authorized keys"
  type        = list(string)
}

variable "node_name" {
  description = "Proxmox node name where containers will be deployed"
  type        = string
  default     = "prox"
}
variable "kubeconfig" {
  description = "Ruta al kubeconfig del clúster"
  type        = string
}

variable "kubeconfig_context" {
  description = "Kubernetes context to use from the kubeconfig file"
  type        = string
  default     = "default"
}

variable "cloudflare_api_token" {
  description = "Token de Cloudflare con permisos DNS"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email de Cloudflare asociado al token"
  type        = string
}
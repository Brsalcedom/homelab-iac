locals {
  gateway_api_version        = "v1.3.0"
  cilium_chart_version       = "1.18.0"
  argocd_chart_version       = "8.1.1"
  cert_manager_chart_version = "v1.18.0"
  cluster_issuer_name        = "cloudflare-clusterissuer"
  base_domain                = "home.cervant.net"
}
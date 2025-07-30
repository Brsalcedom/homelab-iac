provider "kubernetes" {
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path    = var.kubeconfig
    config_context = var.kubeconfig_context
  }
}

provider "kubectl" {
  config_path = var.kubeconfig
}
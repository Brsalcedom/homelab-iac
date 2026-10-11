terraform {
  required_version = ">= 1.9.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      # >=3.3.0 migrated kubernetes_namespace_v1 to the Plugin Framework and
      # requires Resource Identity on every read, which currently breaks
      # refresh for pre-existing namespaces under OpenTofu.
      version = ">= 2.37.1, < 3.3.0"
    }
  }
}

provider "kubernetes" {}

provider "helm" {
  kubernetes = {}
}
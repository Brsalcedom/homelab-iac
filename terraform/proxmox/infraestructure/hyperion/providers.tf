terraform {
  required_version = ">= 1.9.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      # 3.3.0 migrated kubernetes_namespace_v1 to the Plugin Framework and
      # requires Resource Identity on every read. It was pinned below 3.3.0
      # for that, but CI has run 3.3.0 against existing namespaces without
      # refresh errors. Renovate moves this upper bound; check refresh before
      # merging a bump.
      version = "< 3.4.0"
    }
  }
}

provider "kubernetes" {}

provider "helm" {
  kubernetes = {}
}
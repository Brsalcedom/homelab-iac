resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = local.argocd_chart_version
  create_namespace = false

  wait    = true
  timeout = 600

  set = [
    {
      name  = "crds.install"
      value = "false"
    },
    {
      name  = "global.domain"
      value = "argocd.${local.base_domain}"
    },
    {
      name  = "configs.params.server.insecure"
      value = "true"
    },
    {
      name  = "server.service.type"
      value = "ClusterIP"
    }
  ]

  depends_on = [kubernetes_namespace.argocd, time_sleep.after_cilium]
}

resource "kubernetes_manifest" "argocd_route" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = "argocd-route"
      "namespace" = "argocd"
    }
    "spec" = {
      "parentRefs" = [
        {
          "name"        = "cilium-gateway"
          "namespace"   = "cilium-gateway"
          "sectionName" = "https"
        }
      ]
      "hostnames" = [
        "argocd.${local.base_domain}"
      ]
      "rules" = [
        {
          "matches" = [
            {
              "path" = {
                "type"  = "PathPrefix"
                "value" = "/"
              }
            }
          ]
          "backendRefs" = [
            {
              "name" = "argocd-server"
              "port" = 80
            }
          ]
        }
      ]
    }
  }
  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "argocd_project" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "name"      = "homelab"
      "namespace" = "argocd"
      "labels" = {
        "owner"            = "brsalcedom"
        "project-type"     = "homelab"
        "cluster-name"     = "hyperion"
        "k8s-distribution" = "k3s"
      }
    }
    "spec" = {
      "description" = "Proyecto para desplegar apps en el homelab"
      "sourceRepos" = ["*"]
      "destinations" = [
        {
          "namespace" = "*"
          "server"    = "https://kubernetes.default.svc"
        }
      ]
      "clusterResourceWhitelist" = [
        {
          "group" = "*"
          "kind"  = "*"
        }
      ]
      "namespaceResourceWhitelist" = [
        {
          "group" = "*"
          "kind"  = "*"
        }
      ]
      "orphanedResources" = {
        "warn" = true
      }
      "roles" = [
        {
          "name"        = "admin"
          "description" = "Permite control total sobre este proyecto"
          "policies" = [
            "p, proj:homelab:admin, applications, *, homelab/*, allow"
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}


resource "kubernetes_manifest" "argocd_app_of_apps" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "root"
      "namespace" = "argocd"
      "labels" = {
        "owner"            = "brsalcedom"
        "project-type"     = "homelab"
        "cluster-name"     = "hyperion"
        "k8s-distribution" = "k3s"
      }
    }
    "spec" = {
      "project" = "homelab"
      "source" = {
        "repoURL"        = "https://github.com/Brsalcedom/homelab-iac"
        "targetRevision" = "main"
        "path"           = "k8s/applications/argocd"
        "directory" = {
          "recurse" = true
          "include" = "*application.yaml"
        }
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "argocd"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}


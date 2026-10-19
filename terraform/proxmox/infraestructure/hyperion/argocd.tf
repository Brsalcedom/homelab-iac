resource "kubernetes_namespace_v1" "argocd" {
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
      # Escape the dot: the key is literally "server.insecure" in argocd-cmd-params-cm.
      name  = "configs.params.server\\.insecure"
      value = "true"
    },
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      # Log in with Pocket ID. The client IDs and the secret come from the
      # argocd-oidc Secret, which the argocd-sso app syncs from Infisical. Until
      # it exists only the local admin account works, and admin stays enabled
      # as break-glass if Pocket ID is down.
      name  = "configs.cm.oidc\\.config"
      value = <<-EOT
        name: Pocket ID
        issuer: https://pocket.${local.base_domain}
        clientID: $argocd-oidc:clientID
        clientSecret: $argocd-oidc:clientSecret
        cliClientID: $argocd-oidc:cliClientID
        requestedScopes:
          - openid
          - profile
          - email
          - groups
      EOT
    },
    {
      # Users outside argocd-admins get no access.
      name  = "configs.rbac.policy\\.default"
      value = ""
      type  = "string"
    },
    {
      # Escape the commas: Helm splits set values on them.
      name  = "configs.rbac.policy\\.csv"
      value = "g\\, argocd-admins\\, role:admin"
    },
    {
      name  = "configs.rbac.scopes"
      value = "[groups]"
    },
    {
      # ArgoCD talks OIDC to Pocket ID directly; Dex isn't used.
      name  = "dex.enabled"
      value = "false"
    }
  ]

  depends_on = [kubernetes_namespace_v1.argocd, time_sleep.after_cilium]
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
        "path"           = "kubernetes/applications/argocd"
        "directory" = {
          "recurse" = true
          "include" = "*application.yaml"
        }
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "argocd"
      }
      # ArgoCD Image Updater (argocd write-back) sets image overrides on child
      # Applications; keep root from reverting them on sync.
      "ignoreDifferences" = [
        {
          "group"        = "argoproj.io"
          "kind"         = "Application"
          "jsonPointers" = ["/spec/source/kustomize/images"]
        }
      ]
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = ["RespectIgnoreDifferences=true"]
      }
    }
  }

  depends_on = [helm_release.argocd]
}


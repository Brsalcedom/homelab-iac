resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = local.cert_manager_chart_version
  create_namespace = false

  wait    = true
  timeout = 600

  set = [
    {
      name  = "crds.enabled"
      value = "false"
    }
  ]

  set_list = [
    {
      name  = "extraArgs"
      value = ["--dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53", "--dns01-recursive-nameservers-only"]
    }
  ]
  depends_on = [
    helm_release.cilium, kubernetes_namespace.cert_manager, time_sleep.after_cilium
  ]
}

resource "kubernetes_manifest" "clusterissuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "cloudflare-clusterissuer"
    }
    "spec" = {
      "acme" = {
        "email"  = local.cloudflare_email
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "cloudflare-clusterissuer-account-key"
        }
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "apiTokenSecretRef" = {
                  "name" = "cloudflare-api-token"
                  "key"  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

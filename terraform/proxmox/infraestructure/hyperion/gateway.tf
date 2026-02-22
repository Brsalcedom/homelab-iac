resource "kubernetes_namespace" "cilium_gateway" {
  metadata {
    name = "cilium-gateway"
  }
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "wildcard-certificate"
      "namespace" = "cilium-gateway"
    }
    "spec" = {
      "secretName" = "tls-cert"
      "issuerRef" = {
        "name" = "cloudflare-clusterissuer"
        "kind" = "ClusterIssuer"
      }
      "commonName" = "*.${local.base_domain}"
      "dnsNames"   = ["*.${local.base_domain}"]
    }
  }

  depends_on = [
    kubernetes_namespace.cilium_gateway,
    time_sleep.after_cilium,
    helm_release.cert_manager,
    kubernetes_manifest.clusterissuer,
  ]
}

resource "kubernetes_manifest" "cilium_gateway" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "Gateway"
    "metadata" = {
      "name"      = "cilium-gateway"
      "namespace" = "cilium-gateway"
    }
    "spec" = {
      "gatewayClassName" = "cilium"
      "listeners" = [
        {
          "name"     = "https"
          "port"     = 443
          "protocol" = "HTTPS"
          "hostname" = "*.${local.base_domain}"
          "tls" = {
            "mode" = "Terminate"
            "certificateRefs" = [
              {
                "kind" = "Secret"
                "name" = "tls-cert"
              }
            ]
          }
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "All"
            }
          }
        },
        {
          "name"     = "http"
          "port"     = 80
          "protocol" = "HTTP"
          "hostname" = "*.${local.base_domain}"
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "All"
            }
          }
        }
      ]
    }
  }

  depends_on = [
    time_sleep.after_cilium,
    kubernetes_namespace.cilium_gateway,
    kubernetes_manifest.certificate,
  ]
}


resource "kubernetes_manifest" "cilium_redirect_httproute" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = "redirect-to-https"
      "namespace" = "cilium-gateway"
    }
    "spec" = {
      "parentRefs" = [
        {
          "name"        = "cilium-gateway"
          "sectionName" = "http"
        }
      ]
      "hostnames" = ["*.${local.base_domain}"]
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
          "filters" = [
            {
              "type" = "RequestRedirect"
              "requestRedirect" = {
                "scheme"     = "https"
                "statusCode" = 301
              }
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    time_sleep.after_cilium,
    kubernetes_manifest.cilium_gateway,
    kubernetes_namespace.cilium_gateway,
  ]
}

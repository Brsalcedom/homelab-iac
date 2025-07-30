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

  values = [
    yamlencode({
      global = {
        domain = "argocd.${local.base_domain}"
      }

      configs = {
        params = {
          "server.insecure" = true
        }
      }

      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
  depends_on = [kubernetes_namespace.argocd, helm_release.cilium]
}

resource "kubectl_manifest" "argocd_route" {
  yaml_body  = <<YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: argocd-route
      namespace: "argocd"
    spec:
      parentRefs:
        - name: cilium-gateway
          namespace: cilium-gateway
          sectionName: "https"
      hostnames:
      - "argocd.${local.base_domain}"
      rules:
      - matches:
          - path:
              type: PathPrefix
              value: /
        backendRefs:
          - name: argocd-server
            port: 80
YAML
  depends_on = [helm_release.argocd]
}
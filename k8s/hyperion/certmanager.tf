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

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]

  set_list = [
    {
      name  = "extraArgs"
      value = ["--dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53", "--dns01-recursive-nameservers-only"]
    }
  ]
  depends_on = [
    helm_release.cilium, kubernetes_namespace.cert_manager
  ]
}

resource "kubectl_manifest" "cloudflare_api_token_secret" {
  yaml_body = <<YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: cloudflare-api-token-secret
      namespace: "cert-manager"
    type: Opaque
    data:
      api-token: ${base64encode(var.cloudflare_api_token)}
YAML
}



resource "kubectl_manifest" "clusterissuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer_name}
spec:
  acme:
    email: ${var.cloudflare_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cloudflare-clusterissuer-account-key
    solvers:
    - dns01:
        cloudflare:
          email: ${var.cloudflare_email}
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
YAML

  depends_on = [
    helm_release.cert_manager,
    kubectl_manifest.cloudflare_api_token_secret
  ]
}
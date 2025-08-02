resource "null_resource" "gateway_api_crds" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${local.gateway_api_version}/standard-install.yaml"
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = local.cilium_chart_version

  create_namespace = false

  set = [
    {
      name  = "kubeProxyReplacement"
      value = "true"
    },
    {
      name  = "k8sServiceHost"
      value = "127.0.0.1"
    },
    {
      name  = "k8sServicePort"
      value = "6443"
    },
    {
      name  = "ipam.mode"
      value = "cluster-pool"
    },
    {
      name  = "cluster.name"
      value = "hyperion"
    },
    {
      name  = "cluster.id"
      value = "1"
    },
    {
      name  = "loadBalancer.enabled"
      value = "true"
    },
    {
      name  = "externalIPs.enabled"
      value = "true"
    },
    {
      name  = "bpf.masquerade"
      value = "true"
    },
    {
      name  = "hubble.enabled"
      value = "true"
    },
    {
      name  = "hubble.ui.enabled"
      value = "true"
    },
    {
      name  = "hubble.relay.enabled"
      value = "true"
    },
    {
      name  = "prometheus.enabled"
      value = "true"
    },
    {
      name  = "operator.prometheus.enabled"
      value = "true"
    },
    {
      name  = "envoy.enabled"
      value = "true"
    },
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    }
  ]
  depends_on = [
    null_resource.gateway_api_crds
  ]
}
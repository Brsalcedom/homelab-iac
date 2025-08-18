resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = local.cilium_chart_version

  wait             = true
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
      name  = "envoy.enabled"
      value = "true"
    },
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    },
    {
      name  = "operator.replicas"
      value = "1"
    }
  ]
  depends_on = [
    null_resource.gateway_api_crds
  ]
}

resource "time_sleep" "after_cilium" {
  depends_on      = [helm_release.cilium]
  create_duration = "120s"
}
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "vm_stack" {
  name             = "vm"
  repository       = "https://victoriametrics.github.io/helm-charts/"
  chart            = "victoria-metrics-k8s-stack"
  namespace        = kubernetes_namespace_v1.monitoring.metadata[0].name
  create_namespace = true
  wait             = true
  # Optional: Customize values (storage, admin passwords, etc.)
  values = [
    <<-EOF
    grafana:
      enabled: true
      adminPassword: "123password"
      ingress:
        enabled: false # Set to true if you have an Ingress Controller
      service:
        type: ClusterIP    

    victoria-metrics-operator:
      enabled: true

    # This replaces the Prometheus server with VM-native components
    vmsingle:
      enabled: true
      spec:
        retentionPeriod: "1" # 1 month retention
        storage:
          volumeClaimTemplate:
            spec:
              resources:
                requests:
                  storage: 20Gi

    vmalert:
      enabled: true
      spec:
        datasource:
          url: "http://vmsingle-vm-victoria-metrics-k8s-stack.monitoring.svc:8429"
    EOF
  ]
}

# The HTTPRoute (Connects the Gateway to Grafana)
resource "kubectl_manifest" "grafana_route" {
  yaml_body = file("${path.module}/grafana/grafana-route.yml")

  depends_on = [
    helm_release.vm_stack,
    google_container_node_pool.primary_preemptible_nodes
  ]
}

resource "kubectl_manifest" "grafana_healthcheck" {
  yaml_body  = file("${path.module}/grafana/grafana-healthcheck.yml")
  depends_on = [helm_release.vm_stack]
}

resource "kubectl_manifest" "grafana_health_policy" {
  yaml_body  = file("${path.module}/grafana/healthcheck.yml")
  depends_on = [helm_release.vm_stack]
}

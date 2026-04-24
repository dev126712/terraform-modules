resource "helm_release" "trivy_operator" {
  name             = "trivy-operator"
  repository       = "https://aquasecurity.github.io/helm-charts/"
  chart            = "trivy-operator"
  namespace        = "trivy-system"
  create_namespace = true
  depends_on       = [google_container_node_pool.primary_preemptible_nodes]

  set {
    name  = "trivy.vulnerabilityScanCriticalOnly"
    value = "true"
  }
}

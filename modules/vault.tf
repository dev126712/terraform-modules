resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  depends_on       = [google_container_node_pool.primary_preemptible_nodes]

  values = [<<-EOT
    server:
      dev:
        enabled: true # Change to 'false' and add 'ha' for true production
      annotations:
        iam.gke.io/gcp-service-account: ${google_service_account.vault_sa.email}
    injector:
      enabled: true
  EOT
  ]
}

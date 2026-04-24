# 1. Service Account for Trivy (to read your DockerHub/Registry metadata)
resource "google_service_account" "trivy_sa" {
  account_id   = "trivy-operator"
  display_name = "Trivy Operator Workload Identity"
  project      = var.project_id
}

# 2. Service Account for Vault (to store/access secrets in GCP)
resource "google_service_account" "vault_sa" {
  account_id   = "vault-kms-unseal"
  display_name = "Vault KMS Unseal Service Account"
  project      = var.project_id
}

# 3. Allow K8s to "act as" these GCP Service Accounts
resource "google_service_account_iam_member" "trivy_wi" {
  service_account_id = google_service_account.trivy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[trivy-system/trivy-operator]"
}

resource "google_service_account_iam_member" "vault_wi" {
  service_account_id = google_service_account.vault_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[vault/vault]"
}

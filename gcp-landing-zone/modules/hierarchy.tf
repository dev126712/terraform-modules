# ------------------------------------------------------------------------------
# LEVEL 1 FOLDERS (Parent = Organization)
# ------------------------------------------------------------------------------

resource "google_folder" "dev_qa_env" {
  display_name = "Development and QA environment"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "testing_env" {
  display_name = "Testing environment"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "production_env" {
  display_name = "Production environment"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "bootstrap" {
  display_name = "Bootstrap"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "shared_infrastructure" {
  display_name = "Shared infrastructure"
  parent       = "organizations/${var.org_id}"
}

# ------------------------------------------------------------------------------
# LEVEL 2 FOLDERS (Parent = Level 1 Folder)
# ------------------------------------------------------------------------------

resource "google_folder" "testing_subfolder" {
  display_name = "Testing folder"
  parent       = google_folder.testing_env.name
}

# ------------------------------------------------------------------------------
# PROJECTS (Attached to Folders)
# ------------------------------------------------------------------------------

# -- Bootstrap Projects --
resource "google_project" "shared_net" {
  name            = "Shared Networking"
  project_id      = "${var.prefix}-net-host"
  folder_id       = google_folder.shared_infrastructure.name
  billing_account = var.billing_account
  deletion_policy = "DELETE"
  auto_create_network = var.auto_create_network
}

resource "google_project" "seed_project" {
  name            = "Seed"
  project_id      = "${var.prefix}-seed-prj"
  folder_id       = google_folder.bootstrap.name
  billing_account = var.billing_account
  deletion_policy = "DELETE"
  auto_create_network = var.auto_create_network
}

resource "google_project" "cicd_project" {
  name            = "CICD"
  project_id      = "stf${var.prefix}-cicd-prj"
  folder_id       = google_folder.bootstrap.name
  billing_account = var.billing_account
deletion_policy = "DELETE"
  auto_create_network = var.auto_create_network
}

# -- Dev / QA Projects --
resource "google_project" "developer_project" {
  name            = "Developer project"
  project_id      = "${var.prefix}-dev-prj"
  folder_id       = google_folder.dev_qa_env.name
  billing_account = var.billing_account
deletion_policy = "DELETE"
  auto_create_network = var.auto_create_network
}

# -- Testing Projects (Nested in Level 2) --
resource "google_project" "internal_testing_project" {
  name       = "Internal testing project"
  project_id = "${var.prefix}-int-test-prj"

  # This attaches to the nested Level 2 folder
  folder_id       = google_folder.testing_subfolder.name
  billing_account = var.billing_account
deletion_policy = "DELETE"
  auto_create_network = var.auto_create_network
}

# -- Production Project --
resource "google_project" "production_project" {
  name            = "Production project"
  project_id      = "${var.prefix}-prod-prj"
  folder_id       = google_folder.production_env.name
  billing_account = var.billing_account
deletion_policy = "DELETE"
  auto_create_network = var.auto_create_network
}


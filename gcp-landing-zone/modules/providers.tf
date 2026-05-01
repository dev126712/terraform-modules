terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0" # Using the latest major version for Org features
    }
  }

  # It is highly recommended to use a GCS backend for a Landing Zone
  # so that your team can collaborate and the state is locked.
  # backend "gcs" {
  #   bucket  = "your-terraform-state-bucket"
  #   prefix  = "terraform/state/landing-zone"
  # }
}

provider "google" {
  # The "Seed" project is usually where the Terraform Service Account lives
  project = var.seed_project_id
  region  = var.region
  zone    = var.zone
}

# Optional: Beta provider is often needed for advanced Org Policies
provider "google-beta" {
  project = var.seed_project_id
  region  = var.region
  zone    = var.zone
}

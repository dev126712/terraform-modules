terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0" # Current stable version for 2026
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.8.0"
    }
  }
}


# Configure the MongoDB Atlas Provider
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

# Default provider for general resources
provider "google" {
  region = var.region
  zone   = var.zone
}

# Beta provider for Vertex AI and advanced networking features
provider "google-beta" {
  region = var.region
  zone   = var.zone
}

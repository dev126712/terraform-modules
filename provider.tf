terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }

  }
}

data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke_cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${module.gke_cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
  load_config_file       = false
}

provider "kubernetes" {
  host                   = "https://${module.gke_cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
}

###############################################################################
# Backstage Platform — Root Module
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Uncomment and configure for remote state
  # backend "gcs" {
  #   bucket = "your-tfstate-bucket"
  #   prefix = "backstage/terraform.tfstate"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

###############################################################################
# Enable Required GCP APIs
###############################################################################

resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

###############################################################################
# Modules
###############################################################################

module "networking" {
  source = "./modules/networking"

  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  subnet_cidr    = var.subnet_cidr
  connector_cidr = var.connector_cidr

  depends_on = [google_project_service.apis]
}

module "iam" {
  source = "./modules/iam"

  project_id  = var.project_id
  environment = var.environment

  depends_on = [google_project_service.apis]
}

module "artifact_registry" {
  source = "./modules/artifact_registry"

  project_id        = var.project_id
  region            = var.region
  environment       = var.environment
  cloudrun_sa_email = module.iam.cloudrun_sa_email

  depends_on = [google_project_service.apis]
}

module "secrets" {
  source = "./modules/secrets"

  project_id           = var.project_id
  region               = var.region
  environment          = var.environment
  cloudrun_sa_email    = module.iam.cloudrun_sa_email
  github_token         = var.github_token
  backstage_app_config = var.backstage_app_config

  depends_on = [module.iam]
}

module "database" {
  source = "./modules/database"

  project_id             = var.project_id
  region                 = var.region
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_ip_range_name  = module.networking.private_ip_range_name
  db_tier                = var.db_tier
  db_availability_type   = var.db_availability_type
  db_deletion_protection = var.db_deletion_protection
  cloudrun_sa_email      = module.iam.cloudrun_sa_email
  db_password_secret_id  = module.secrets.db_password_secret_id
  db_password            = module.secrets.db_password_value

  depends_on = [module.networking, module.secrets]
}

module "cloud_run" {
  source = "./modules/cloud_run"

  project_id                  = var.project_id
  region                      = var.region
  environment                 = var.environment
  backstage_image             = var.backstage_image
  cloudrun_sa_email           = module.iam.cloudrun_sa_email
  vpc_connector_id            = module.networking.vpc_connector_id
  db_instance_connection      = module.database.instance_connection_name
  db_name                     = module.database.db_name
  db_user                     = module.database.db_user
  db_password_secret_id       = module.secrets.db_password_secret_id
  db_password_secret_version  = module.secrets.db_password_secret_version
  github_token_secret_id      = module.secrets.github_token_secret_id
  github_token_secret_version = module.secrets.github_token_secret_version
  app_config_secret_id        = module.secrets.app_config_secret_id
  app_config_secret_version   = module.secrets.app_config_secret_version
  min_instances               = var.min_instances
  max_instances               = var.max_instances
  cpu                         = var.cloud_run_cpu
  memory                      = var.cloud_run_memory
  allow_public_access         = var.allow_public_access

  depends_on = [module.database, module.secrets, module.networking, module.iam]
}

# 1. Create a Project
resource "mongodbatlas_project" "aiops_project" {
  name   = "AIOps"
  org_id = var.atlas_org_id
}

# 2. Create the Cluster on GCP
resource "mongodbatlas_cluster" "aiops_cluster" {
  project_id   = mongodbatlas_project.aiops_project.id
  name         = "aiops-pipeline-cluster"
  cluster_type = "REPLICASET"
  
  # Provider Settings for GCP
  provider_name               = "GCP"
  provider_instance_size_name = var.provider_instance_size_name
  provider_region_name        = var.provider_region_name
}

resource "mongodbatlas_database_user" "aiops_user" {
  username           = "aiops"
  password           = var.atlas_user_password
  project_id         = mongodbatlas_project.aiops_project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "aiops" # Matches your app's DB name
  }
}

# 4. IP Access List (Whitelist)
# In production, change this to your GKE/Cloud Run outbound IP
resource "mongodbatlas_project_ip_access_list" "allow_all" {
  project_id = mongodbatlas_project.aiops_project.id
  cidr_block = "0.0.0.0/0" 
  comment    = "Temporary allow all - narrow this down for production!"
}
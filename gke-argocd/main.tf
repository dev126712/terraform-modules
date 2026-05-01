
module "gke_cluster" {
  source = "./modules"

  # Cluster Configuration
  project_id          = "project-test-490416"
  cluster_name        = "my-gke-cluster"
  cluster_region      = "us-central1"
  region              = "us-central1"
  node_count          = 1
  deletion_protection = false

  # Node Pool Configuration
  node_pool_name  = "general-purpose-pool"
  machine_type    = "e2-medium"
  node_pool_count = 2 # This is the number of nodes per zone 
  node_locations = [ "us-central1-a", "us-central1-b", "us-central1-c" ]

  # node_locations defaults to ["us-central1-a", "us-central1-b", "us-central1-c"]
  zone_count = 2 # This tells the module to slice the first 2 zones

  # Scaling & Management
  min_node_pool_count = 1
  max_node_pool_count = 5
  auto_repair         = true
  auto_upgrade        = true

  static_ip_name = "lb_name"

  # ArgoCD dynamic vars
  argocd_app_name = "root-app"
  repo_url        = "https://github.com/dev126712/microservice-charts-deployment.git"
  domain_name     = "argocd.example.com"
  target_revision = "HEAD"
  app_path        = "application-manifest"
  sync_prune      = true
  sync_self_heal  = true
}

# module "gke_cluster" {
#   source = "./modules"

#   # Cluster Configuration
#   project_id          = ""
#   cluster_name        = ""
#   cluster_region      = ""
#   region              = ""
#   node_count          = 
#   deletion_protection = 

#   # Node Pool Configuration
#   node_pool_name  = ""
#   machine_type    = ""
#   node_pool_count =  
#   node_locations = [ "" ]

#   zone_count =

#   # Scaling & Management
#   min_node_pool_count =
#   max_node_pool_count =
#   auto_repair         =
#   auto_upgrade        =

#   static_ip_name = ""

#   # ArgoCD dynamic vars
#   argocd_app_name = ""
#   repo_url        = ""
#   domain_name     = ""
#   target_revision = ""
#   app_path        = ""
#   sync_prune      =
#   sync_self_heal  =
# }

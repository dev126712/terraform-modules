
module "gke_cluster" {
  source = "./modules"

  # Cluster Configuration
  project_id          = var.project_id
  cluster_name        = "my-gke-cluster"
  cluster_region      = "us-central1"
  region              = "us-central1"
  node_count          = 1
  deletion_protection = false

  # Node Pool Configuration
  node_pool_name  = "general-purpose-pool"
  machine_type    = "e2-medium"
  node_pool_count = 2 # This is the number of nodes per zone 

  # Scaling & Management
  min_node_pool_count = 1
  max_node_pool_count = 5
  auto_repair         = true
  auto_upgrade        = true

  # node_locations defaults to ["us-central1-a", "us-central1-b", "us-central1-c"] [cite: 2]
  zone_count = 2 # This tells the module to slice the first 2 zones

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


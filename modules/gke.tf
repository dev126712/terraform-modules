resource "google_container_cluster" "primary" {
  name                = var.cluster_name
  location            = var.cluster_region
  project             = var.project_id
  initial_node_count  = var.node_count
  deletion_protection = var.deletion_protection # For demo purposes
  network             = google_compute_network.my-network.id
  subnetwork          = google_compute_subnetwork.custum-subnet.id

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  gateway_api_config {
    # 'CHANNEL_STANDARD' enables the stable Gateway API resources
    channel = "CHANNEL_STANDARD"
  }

}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.node_pool_name
  project    = google_container_cluster.primary.project
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = var.node_pool_count
  # enable_private_nodes = true

  node_locations = slice(var.node_locations, 0, var.zone_count)

  node_config {
    preemptible  = false
    machine_type = var.machine_type
    # enable_private_nodes = true
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

  }

  autoscaling {
    min_node_count = var.min_node_pool_count
    max_node_count = var.max_node_pool_count
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }
}

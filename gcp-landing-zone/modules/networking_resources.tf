resource "google_compute_network" "shared_vpc" {
  name                    = "shared-vpc-network"
  auto_create_subnetworks = false
  project                 = google_project.shared_net.project_id
}

resource "google_compute_subnetwork" "prod_subnet" {
  name          = "prod-subnet-01"
  ip_cidr_range = "10.0.1.0/24"
  region        = "northamerica-northeast1"
  network       = google_compute_network.shared_vpc.id
  project       = google_project.shared_net.project_id

  private_ip_google_access = true
}

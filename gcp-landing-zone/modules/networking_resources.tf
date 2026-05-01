resource "google_compute_network" "shared_vpc" {
  name                    = "shared-vpc-network"
  auto_create_subnetworks = false
  project                 = google_project.shared_net.project_id
}

# --- Development Subnet ---
resource "google_compute_subnetwork" "dev_subnet" {
  name                     = "dev-subnet-01"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.shared_vpc.id
  project                  = google_project.shared_net.project_id
  private_ip_google_access = true
}

# --- Testing Subnet ---
resource "google_compute_subnetwork" "test_subnet" {
  name                     = "test-subnet-01"
  ip_cidr_range            = "10.0.3.0/24"
  region                   = var.region
  network                  = google_compute_network.shared_vpc.id
  project                  = google_project.shared_net.project_id
  private_ip_google_access = true
}

# --- Production Subnet (Already have this) ---
resource "google_compute_subnetwork" "prod_subnet" {
  name                     = "prod-subnet-01"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.shared_vpc.id
  project                  = google_project.shared_net.project_id
  private_ip_google_access = true
}


# --- Cloud NAT Gateway ---
resource "google_compute_router" "router" {
  name    = "shared-vpc-router"
  region  = var.region
  network = google_compute_network.shared_vpc.id
  project = google_project.shared_net.project_id
}


resource "google_compute_router_nat" "nat" {
  name                   = "shared-vpc-nat"
  router                 = google_compute_router.router.name
  region                 = var.region
  project                = google_project.shared_net.project_id
  nat_ip_allocate_option = "AUTO_ONLY"

  # This allows all subnets in this region to use the NAT
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
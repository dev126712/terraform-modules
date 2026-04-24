resource "google_compute_network" "my-network" {
  name                    = "custom-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "custum-subnet" {
  name          = "subnetwork"
  ip_cidr_range = "10.10.0.0/16"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.my-network.id
}

resource "google_compute_firewall" "allow_intern" {
  name    = "internal-firewall"
  network = google_compute_network.my-network.id
  project = var.project_id
  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

resource "google_compute_firewall" "extern_intern" {
  name    = "extern-firewall"
  network = google_compute_network.my-network.id
  project = var.project_id
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["gke-${var.cluster_name}"]
}

resource "google_compute_firewall" "gke_allow" {
  name    = "gke-firewall"
  network = google_compute_network.my-network.id
  project = var.project_id
  allow {
    protocol = "tcp"
  }
  source_ranges = ["10.10.0.0/16", "130.211.0.0/22", "35.191.0.0/16"]
}

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.custum-subnet.region
  network = google_compute_network.my-network.id
  project = var.project_id
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


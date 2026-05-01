# --- Allow SSH ---
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.shared_vpc.name
  project = google_project.shared_net.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# --- Allow Google Cloud Health Checks ---
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = google_compute_network.shared_vpc.name
  project = google_project.shared_net.project_id

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# --- Allow Internal Traffic within the SAME Environment ---
resource "google_compute_firewall" "allow_intra_env" {
  name    = "allow-intra-environment-traffic"
  network = google_compute_network.shared_vpc.name
  project = google_project.shared_net.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "10.0.1.0/24", # Prod
    "10.0.2.0/24", # Dev
    "10.0.3.0/24"  # Test
  ]
}

# --- Deny Inter-Environment Traffic ---
resource "google_compute_firewall" "deny_dev_to_prod" {
  name     = "deny-dev-to-prod"
  network  = google_compute_network.shared_vpc.name
  project  = google_project.shared_net.project_id
  priority = 1000

  deny {
    protocol = "all"
  }

  source_ranges      = ["10.0.2.0/24"] # Dev
  destination_ranges = ["10.0.1.0/24"] # Prod
}
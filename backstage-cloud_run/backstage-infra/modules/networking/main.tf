###############################################################################
# Module: networking
# Creates: VPC, Private Subnet, Cloud Router, Cloud NAT,
#          Private Service Access (for Cloud SQL private IP),
#          Serverless VPC Access Connector (for Cloud Run → Cloud SQL),
#          Firewall Rules
###############################################################################

###############################################################################
# VPC
###############################################################################

resource "google_compute_network" "vpc" {
  name                    = "backstage-${var.environment}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  description = "Backstage platform VPC — ${var.environment}"
}

###############################################################################
# Private Subnet
###############################################################################

resource "google_compute_subnetwork" "private" {
  name                     = "backstage-${var.environment}-private-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true # Allows VMs to reach Google APIs without NAT

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

###############################################################################
# Private Service Access — required for Cloud SQL private IP
###############################################################################

resource "google_compute_global_address" "private_ip_range" {
  name          = "backstage-${var.environment}-sql-private-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

###############################################################################
# Cloud Router
###############################################################################

resource "google_compute_router" "router" {
  name    = "backstage-${var.environment}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

###############################################################################
# Cloud NAT — outbound internet for private subnet (pulling images, etc.)
###############################################################################

resource "google_compute_router_nat" "nat" {
  name                               = "backstage-${var.environment}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

###############################################################################
# Serverless VPC Access Connector
# Allows Cloud Run to reach private resources (Cloud SQL) inside the VPC
###############################################################################

resource "google_vpc_access_connector" "connector" {
  name          = "backstage-${var.environment}-connector"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.connector_cidr # Must be a /28, not overlapping other CIDRs

  min_instances = 2
  max_instances = 10
  machine_type  = "e2-micro"
}

###############################################################################
# Firewall Rules
###############################################################################

# Deny all ingress by default (GCP default, made explicit)
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "backstage-${var.environment}-deny-all-ingress"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  description   = "Deny all ingress — explicit baseline"
}

# Allow internal VPC traffic
resource "google_compute_firewall" "allow_internal" {
  name      = "backstage-${var.environment}-allow-internal"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1000

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

  source_ranges = [var.vpc_cidr, var.connector_cidr]
  description   = "Allow all traffic within VPC and connector range"
}

# Allow GCP health checks (required for load balancers / Cloud Run)
resource "google_compute_firewall" "allow_health_checks" {
  name      = "backstage-${var.environment}-allow-health-checks"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  # GCP health check probe ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  description   = "Allow GCP load balancer health check probes"
}

# Allow IAP (Identity-Aware Proxy) for SSH/admin access
resource "google_compute_firewall" "allow_iap" {
  name      = "backstage-${var.environment}-allow-iap"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  description   = "Allow IAP tunnel for SSH"
}

# Allow VPC connector to reach Cloud SQL (port 5432)
resource "google_compute_firewall" "allow_connector_to_sql" {
  name      = "backstage-${var.environment}-allow-connector-sql"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 900

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [var.connector_cidr]
  description   = "Allow VPC connector (Cloud Run) to reach Cloud SQL"
}

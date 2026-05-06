###############################################################################
# Module: networking — outputs.tf
###############################################################################

output "vpc_id" {
  description = "VPC network self_link"
  value       = google_compute_network.vpc.self_link
}

output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "Private subnet self_link"
  value       = google_compute_subnetwork.private.self_link
}

output "vpc_connector_id" {
  description = "Serverless VPC Access Connector ID"
  value       = google_vpc_access_connector.connector.id
}

output "private_ip_range_name" {
  description = "Name of the private IP range for Private Service Access"
  value       = google_compute_global_address.private_ip_range.name
}

output "nat_name" {
  description = "Cloud NAT name"
  value       = google_compute_router_nat.nat.name
}

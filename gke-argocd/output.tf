output "gke_cluster_name" {
  description = "The name of the GKE cluster."
  value       = module.gke_cluster.cluster_name
}

output "gke_cluster_endpoint" {
  description = "The IP address of the Kubernetes master."
  value       = module.gke_cluster.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "The public certificate of the GKE cluster master."
  value       = module.gke_cluster.cluster_ca_certificate
}

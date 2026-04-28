output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.frontend.ip_address
  description = "The external IP address of the Load Balancer with CDN"
}
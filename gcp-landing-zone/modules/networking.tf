resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.shared_net.project_id
}

resource "google_compute_shared_vpc_service_project" "prod_attach" {
  host_project    = google_project.shared_net.project_id
  service_project = google_project.production_project.project_id

  depends_on = [google_compute_shared_vpc_host_project.host]
}

resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.shared_net.project_id
}

resource "google_compute_shared_vpc_service_project" "prod_attach" {
  host_project    = google_project.shared_net.project_id
  service_project = google_project.production_project.project_id

  depends_on = [google_compute_shared_vpc_host_project.host]
}

resource "google_compute_shared_vpc_service_project" "dev-qa_attach" {
  host_project    = google_project.shared_net.project_id
  service_project = google_project.developer_project.project_id

  depends_on = [google_compute_shared_vpc_host_project.host]
}

resource "google_compute_shared_vpc_service_project" "test_attach" {
  host_project    = google_project.shared_net.project_id
  service_project = google_project.internal_testing_project.project_id

  depends_on = [google_compute_shared_vpc_host_project.host]
}

# Allow Dev Project to use Dev Subnet
resource "google_compute_subnetwork_iam_member" "dev_user" {
  project    = google_project.shared_net.project_id
  region     = google_compute_subnetwork.dev_subnet.region
  subnetwork = google_compute_subnetwork.dev_subnet.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${google_project.developer_project.number}@compute-system.iam.gserviceaccount.com"
}

# Allow Test Project to use Test Subnet
resource "google_compute_subnetwork_iam_member" "test_user" {
  project    = google_project.shared_net.project_id
  region     = google_compute_subnetwork.test_subnet.region
  subnetwork = google_compute_subnetwork.test_subnet.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${google_project.internal_testing_project.number}@compute-system.iam.gserviceaccount.com"
}

# Allow Production Project to use Production Subnet
resource "google_compute_subnetwork_iam_member" "prod_user" {
  project    = google_project.shared_net.project_id
  region     = google_compute_subnetwork.prod_subnet.region
  subnetwork = google_compute_subnetwork.prod_subnet.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${google_project.production_project.number}@compute-system.iam.gserviceaccount.com"
}
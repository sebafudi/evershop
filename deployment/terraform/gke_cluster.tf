resource "google_container_cluster" "gke_cluster" {
  name     = "evershop-cluster"
  location = "europe-west1"

  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on = [
    google_project_service.container,
  ]
  deletion_protection = false
}

resource "google_container_node_pool" "primary_pool" {
  name       = "primary-pool"
  location   = "europe-west1"
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 2

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
    disk_size_gb = 25

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

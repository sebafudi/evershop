resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  name        = "evershop-pipeline"
  description = "Delivery pipeline for Evershop"
  location    = "europe-west1"

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.prod.name
    }
  }
}

resource "google_clouddeploy_target" "prod" {
  name        = "prod"
  description = "Production environment"
  location    = "europe-west1"

  gke {
    cluster = google_container_cluster.gke_cluster.name
  }

  depends_on = [
    google_project_service.clouddeploy
  ]
}

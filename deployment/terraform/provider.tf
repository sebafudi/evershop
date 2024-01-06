provider "google" {
  credentials = file("../../deployment.env/credentials.json")
  project     = local.project_id
  region      = "europe-west1"
}

data "google_client_config" "provider" {}

resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager,
  ]
}

resource "google_project_service" "sourcerepo" {
  service = "sourcerepo.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager,
  ]
}

resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager,
  ]
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager,
  ]
}

resource "google_project_service" "clouddeploy" {
  service = "clouddeploy.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager,
  ]
}

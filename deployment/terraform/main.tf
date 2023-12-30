variable "project" {
  type    = string
  default = "playground-s-11-18d0bb4e"
}

provider "google" {
  credentials = file("../../.env/credentials.json")
  project     = var.project
  region      = "europe-west1"
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "sourcerepo" {
  service = "sourcerepo.googleapis.com"
}


resource "google_sourcerepo_repository" "evershop_repo" {
  name = "evershop-repo"
}

resource "google_cloudbuild_trigger" "gcp_repo_trigger" {
  project     = var.project
  name        = "gcp-repo-trigger"
  description = "Trigger for main branch on GCP Repo"
  filename    = "cloudbuild.yaml" # This file should be in your GCP repository

  included_files = [
    "**",
  ]

  trigger_template {
    repo_name   = google_sourcerepo_repository.evershop_repo.name
    branch_name = "^main$"
  }
}

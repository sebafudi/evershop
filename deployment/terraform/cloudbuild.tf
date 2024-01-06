resource "google_sourcerepo_repository" "evershop_repo" {
  name = "evershop-repo"
  depends_on = [
    google_project_service.sourcerepo,
  ]
}

resource "google_cloudbuild_trigger" "evershop_repo_trigger" {
  project     = data.google_client_config.provider.project
  name        = "evershop-repo-trigger"
  description = "Trigger for evershop-repo"
  filename    = "cloudbuild.yaml"

  included_files = [
    "**",
  ]

  trigger_template {
    repo_name   = google_sourcerepo_repository.evershop_repo.name
    branch_name = "^main$"
  }
  depends_on = [
    google_project_service.cloudbuild,
    google_project_service.sourcerepo,
  ]
}

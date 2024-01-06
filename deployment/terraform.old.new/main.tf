# variable "project" {
#   type    = string
#   default = "playground-s-11-18d0bb4e"
# }

locals {
  raw_data   = jsondecode(file("../../deployment.env/credentials.json"))
  project_id = local.raw_data.project_id
}

provider "google" {
  credentials = file("../../deployment.env/credentials.json")
  project     = local.project_id
  region      = "europe-west1"
}
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
}

resource "google_sourcerepo_repository" "evershop_repo" {
  name = "evershop-repo"
  depends_on = [
    google_project_service.cloudresourcemanager,
    google_project_service.sourcerepo,
  ]
}

resource "google_cloudbuild_trigger" "gcp_repo_trigger" {
  project     = local.project_id
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
  depends_on = [
    google_project_service.cloudresourcemanager,
    google_project_service.cloudbuild,
    google_project_service.sourcerepo,
  ]
}

resource "google_project_service" "sqladmin_api" {
  service = "sqladmin.googleapis.com"
}


resource "google_sql_database_instance" "postgres_instance" {
  name             = "my-postgres-instance"
  database_version = "POSTGRES_15"
  region           = "europe-west1"

  settings {
    tier = "db-f1-micro"
  }

  depends_on = [
    google_project_service.sqladmin_api,
  ]
  deletion_protection = false
}

resource "google_sql_database" "default_db" {
  name     = "evershop"
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "default" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres_instance.name
  password = "postgres"
}

# firewall to allow access to postgres instance
resource "google_compute_firewall" "postgres" {
  name    = "postgres"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["0.0.0.0/0"]


}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

data "google_client_config" "provider" {}

resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster"
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


provider "kubernetes" {
  host  = google_container_cluster.gke_cluster.endpoint
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate,
  )
}

# resource "kubernetes_deployment" "example" {
#   metadata {
#     name = "example-deployment"
#   }

#   spec {
#     replicas = 3

#     selector {
#       match_labels = {
#         app = "example"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "example"
#         }
#       }

#       spec {
#         container {
#           image = "gcr.io/${local.project_id}/evershop:latest"
#           name  = "example"
#         }
#       }
#     }
#   }

#   depends_on = [
#     google_container_node_pool.primary_pool,
#   ]

# }

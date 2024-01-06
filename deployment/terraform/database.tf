
resource "google_sql_database_instance" "evershop_postgres_instance" {
  name             = "evershop-postgres"
  database_version = "POSTGRES_15"
  region           = "europe-west1"

  settings {
    tier = "db-f1-micro"
  }

  depends_on = [
    google_project_service.sqladmin,
  ]
  deletion_protection = false
}

resource "google_sql_database" "default_db" {
  name     = "evershop"
  instance = google_sql_database_instance.evershop_postgres_instance.name
}

resource "google_sql_user" "default" {
  name     = "postgres"
  instance = google_sql_database_instance.evershop_postgres_instance.name
  password = "postgres"
}

# resource "google_compute_firewall" "postgres" {
#   name    = "postgres"
#   network = "default"

#   allow {
#     protocol = "tcp"
#     ports    = ["5432"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

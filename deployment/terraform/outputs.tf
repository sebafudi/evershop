output "gke_cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "repository_url" {
  value = google_sourcerepo_repository.evershop_repo.url
}

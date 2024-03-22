resource "google_storage_bucket" "repo_sources" {
    name = "${var.repo_sources}_${var.environment}"
    storage_class = "REGIONAL"
    location = var.region
}

output "repo_sources_name" {
    value = google_storage_bucket.repo_sources.name
  
}


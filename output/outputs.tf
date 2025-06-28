output "artifactregistry_service_account" {
  value = google_project_service_identity.artifactregistry.email
}

output "cloud_asset_email" {
  value = google_project_service_identity.artifactregistry.email
}

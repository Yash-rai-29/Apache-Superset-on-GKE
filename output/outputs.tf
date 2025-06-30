output "artifact_registry_service_identity" {
  value = google_project_service_identity.artifact_registry.email
  description = "Artifact Registry Service Account"
}

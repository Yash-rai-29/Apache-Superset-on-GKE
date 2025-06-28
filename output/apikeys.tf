resource "google_project_iam_member" "api_keys_disable" {
  project = var.project_id
  role    = "roles/apikeys.admin"
  member  = "allUsers"

  condition {
    title       = "API Key Restriction"
    description = "Deny all API Key creation"
    expression  = "resource.name.startsWith(\"projects/${var.project_id}/locations/global/\")"
  }
}

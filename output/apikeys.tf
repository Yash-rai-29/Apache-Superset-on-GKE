resource "google_project_iam_member" "api_keys_remover" {
  project = var.project_id
  role    = "roles/apikeys.admin"
  member  = "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
}

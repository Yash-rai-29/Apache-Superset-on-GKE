data "google_project_iam_policy" "project" {
  provider = google
  project = var.project_id
}

resource "google_project_iam_member" "no_service_account_user" {
  provider = google
  project = var.project_id
  role   = "roles/iam.serviceAccountUser"
  member = "allUsers"
}

resource "google_project_iam_member" "no_service_account_token_creator" {
  provider = google
  project = var.project_id
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "allUsers"
}

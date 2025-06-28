data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "service_account_token_creator" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "allUsers"
}

resource "google_project_iam_member" "service_account_user" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "allUsers"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_binding" "service_account_token_creator" {
  provider = google
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_binding" "service_account_user" {
  provider = google
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "admin" {
  provider = google
  project = data.google_project.project.project_id
  role    = "roles/owner"
  members = []
}

resource "google_service_account" "accounts" {
  provider = google
  account_id   = "twitch-login"
  project      = var.project_id
}

resource "google_service_account" "accounts_compute" {
  provider = google
  account_id   = "compute"
  project      = var.project_id
}

resource "google_service_account" "accounts_firebase" {
  provider = google
  account_id   = "firebase"
  project      = var.project_id
}



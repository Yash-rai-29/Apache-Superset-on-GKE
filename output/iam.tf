resource "google_project_service" "cloudasset" {
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "cloudasset_service_agent" {
  project = var.project_id
  role = "roles/cloudasset.serviceAgent"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"

  depends_on = [google_project_service.cloudasset]
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_binding" "no_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "no_service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_member" "service_account_separation" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:test-user@example.com"
}

resource "google_project_iam_member" "service_account_no_admin" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_no_admin_appspot" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_no_admin_compute" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_no_admin_firebase" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_service_account_iam_binding" "service_account_keys" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  role              = "roles/viewer"
  members           = []
}

resource "google_service_account_iam_binding" "service_account_keys_compute" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/30647320905-compute@developer.gserviceaccount.com"
  role              = "roles/viewer"
  members           = []
}

resource "google_service_account" "appspot_account" {
  account_id   = "aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
  disabled     = true
  display_name = "Unused Appspot Service Account"
  project      = var.project_id
}

resource "google_service_account" "firebase_account" {
  account_id   = "firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  disabled     = true
  display_name = "Unused Firebase Service Account"
  project      = var.project_id
}

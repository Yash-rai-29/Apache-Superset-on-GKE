data "google_project_iam_policy" "project" {
  project = var.project_id
}

resource "google_project_iam_member" "remove_editor_compute" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:30647320905-compute@developer.gserviceaccount.com"

  lifecycle {
    replace_triggered_by = [data.google_project_iam_policy.project]
  }
}

resource "google_project_iam_member" "remove_editor_firebase" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"

  lifecycle {
    replace_triggered_by = [data.google_project_iam_policy.project]
  }
}

resource "google_project_iam_binding" "service_account_binding" {
  project = var.project_id
  role    = "roles/firebase.sdkAdminServiceAgent"
  members = [
    "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
  ]
}

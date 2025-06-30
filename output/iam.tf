resource "google_project_iam_member" "twitch_login_firebase_sdkAdminServiceAgent" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/firebase.sdkAdminServiceAgent"
  member = "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "appspot_editor" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/editor"
  member = "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "compute_editor" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/editor"
  member = "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "firebase_adminsdk_storage_admin" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/storage.admin"
  member = "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_binding" "service_account_roles_compute" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/editor"
  members = [
    "serviceAccount:30647320905-compute@developer.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "service_account_roles_appspot" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/editor"
  members = [
    "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com",
  ]
}

resource "google_project_iam_member" "twitch_login_firebase_admin_sdk" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/firebase.sdkAdminServiceAgent"
  member = "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "firebase_adminsdk_storage_admin" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/storage.admin"
  member = "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

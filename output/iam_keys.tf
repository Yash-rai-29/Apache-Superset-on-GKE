data "google_project" "project" {
 project_id = var.project_id
}

locals {
  project_number = data.google_project.project.number
}

resource "google_service_account_key" "key_twitch_login" {
  service_account_id = "twitch-login@${var.project_id}.iam.gserviceaccount.com"
  key_algorithm = "KEY_ALG_RSA_2048"
}

resource "google_service_account_key" "key_compute" {
  service_account_id = "${local.project_number}-compute@developer.gserviceaccount.com"
  key_algorithm = "KEY_ALG_RSA_2048"
}

resource "null_resource" "delete_old_keys_twitch" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [
    google_service_account_key.key_twitch_login,
  ]
}

resource "time_rotating" "wait_before_delete_twitch" {
  rotation_days = var.key_deletion_days
  depends_on = [
    null_resource.delete_old_keys_twitch
  ]
}

resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role = "roles/viewer"
  member  = "user:manan@aviato.consulting"
}

resource "google_storage_bucket" "all_logs" {
  name          = "${var.project_id}-all-logs"
  location      = "US"
  force_destroy = true
  project = var.project_id
}

resource "google_storage_bucket_iam_binding" "logs_access" {
  bucket  = google_storage_bucket.all_logs.name
  members = ["allUsers"]
  role    = "roles/storage.objectViewer"
}

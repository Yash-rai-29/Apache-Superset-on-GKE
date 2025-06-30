resource "google_logging_project_sink" "default" {
  name        = "all-logs-to-gcs"
  project     = var.project_id
  destination = "storage.googleapis.com/${google_storage_bucket.log_sink_bucket.name}"
  filter      = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\""

  unique_writer_identity = true
}

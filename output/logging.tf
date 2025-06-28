resource "google_logging_project_sink" "default" {
  name                    = "all-logs-to-storage"
  description             = "Sink for all logs in the project"
  destination             = "storage.googleapis.com/${var.project_id}-all-logs"
  filter                  = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
  project                 = var.project_id
  unique_writer_identity  = true
}

resource "google_storage_bucket" "logging_bucket" {
  name                        = "${var.project_id}-all-logs"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

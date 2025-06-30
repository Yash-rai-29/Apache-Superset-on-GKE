resource "google_logging_project_sink" "default_sink" {
  name        = "all-logs-to-storage"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
}

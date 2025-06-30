resource "google_project_service" "cloudasset" {
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

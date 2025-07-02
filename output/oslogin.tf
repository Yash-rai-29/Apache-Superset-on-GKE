resource "google_project_metadata" "project" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_project_metadata" "oslogin" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

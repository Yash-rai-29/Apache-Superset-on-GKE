resource "google_project_service" "containerregistry" {
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_registry" "registry" {
  location = "us"
  project = var.project_id

  depends_on = [google_project_service.containerregistry]
}

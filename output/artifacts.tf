resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "my_repo" {
  location = "us-central1"
  repository_id = "my-repo"
  format = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_analysis_occurrence" "note_occurrence" {
  note_name   = "projects/${var.project_id}/notes/harrier-container-scan"
  resource_uri = "https://gcr.io/my-project/my-image:123"
  package_issue {
    affected_location {
      cpe_uri   = "cpe:/o:debian:debian_linux:8"
      package   = "foo"
      version {
        epoch = "6"
        name  = "1.2.3"
      }
    }
    type = "PACKAGE_VULNERABILITY"
  }

  depends_on = [google_artifact_registry_repository.my_repo]
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google-beta
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_iam_member" "artifactregistry" {
  provider = google-beta
  project  = var.project_id
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}

resource "google_container_analysis_occurrence" "container_analysis" {
  project               = var.project_id
  note_name             = "providers/goog/notes/generic"
  resource_uri          = "https://gcr.io/google_containers/busybox"
  remediation           = "upgrade"
  create_time           = "2018-04-23T15:04:04.987Z"

  attestation {
    generic_signed_attestation {
      content_type = "CONTENT_TYPE_RAW"
      signature    = "MEUCIQCQWJG0s7EpHK0qjPjWFn9B9q3VznKQMjknzYqt90wqmgIga5cT8mB/MhypE+WqBNtydpQ9E6wZ2N2w+80C6o2Gg0="
      serialized_payload = "eyJjb250ZW50Ijp7ImJ1aWxkSW5mb3JtYXRpb24iOnsibnVtbWkiOiJidXN5Ym94In19fQ=="
    }
  }

  effective_labels = {
    label-one = "value-one"
  }
}

resource "google_project_iam_member" "gcr_sa_role" {
  project = var.project_id
  role    = "roles/containeranalysis.occurrences.viewer"
  member  = "allUsers"
}

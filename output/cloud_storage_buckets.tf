resource "google_storage_bucket" "appspot_bucket" {
  provider = google
  name                        = "${var.project_id}.appspot.com"
  project                     = var.project_id
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "aviato_bucket" {
  provider = google
  name                        = "${var.project_id}_bucket"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "staging_bucket" {
  provider = google
  name                        = "staging.${var.project_id}.appspot.com"
  project                     = var.project_id
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

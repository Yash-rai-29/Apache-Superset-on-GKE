resource "google_storage_bucket" "default_bucket_level_access" {
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  project                     = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_bucket" {
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  project                     = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "staging_bucket_level_access" {
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  project                     = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "log_sink_bucket" {
  name                        = var.log_sink_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
}

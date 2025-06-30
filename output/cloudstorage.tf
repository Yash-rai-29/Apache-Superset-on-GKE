resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = true
  uniform_bucket_level_access = true
}

output "default_ssh_allowed_sources" {
  value       = var.default_ssh_allowed_sources
  description = "The allowed source ranges for SSH access."
}

output "default_rdp_allowed_sources" {
  value       = var.default_rdp_allowed_sources
  description = "The allowed source ranges for RDP access."
}

output "logging_bucket_name" {
  value       = google_storage_bucket.logging_bucket.name
  description = "The name of the GCS bucket used for logging."
}

output "regions_flow_logs_enabled" {
  value = keys(google_compute_subnetwork.default)
  description = "Regions with flow logs enabled on the default subnet"
}

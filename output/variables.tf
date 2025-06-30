variable "project_id" {
  type        = string
  description = "The ID of the project"
  default     = "aviato-game-fight-rvxirf"
}

variable "region" {
  type        = string
  description = "The region to deploy resources to"
  default     = "us-central1"
}

variable "default_ssh_source_ranges" {
  type = list(string)
  default = [
    "10.0.0.0/8",
  ]
  description = "Permitted IP ranges for SSH access"
}

variable "default_rdp_source_ranges" {
  type = list(string)
  default = [
    "10.0.0.0/8",
  ]
  description = "Permitted IP ranges for RDP access"
}

variable "log_sink_bucket_name" {
  type        = string
  description = "Name of the bucket to store logs"
  default     = "aviato-game-fight-rvxirf-logs"
}

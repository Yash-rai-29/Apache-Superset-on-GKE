variable "project_id" {
  type        = string
  description = "The GCP project ID."
  default     = "aviato-game-fight-rvxirf"
}

variable "default_region" {
  type        = string
  description = "The default GCP region."
  default     = "us-central1"
}

variable "default_zones" {
  type    = list(string)
  default = ["us-central1-a", "us-central1-b"]
}

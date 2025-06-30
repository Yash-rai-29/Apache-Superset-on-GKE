variable "project_id" {
  type        = string
  description = "The ID of the project"
  default     = "aviato-game-fight-rvxirf"
}

variable "location" {
  type        = string
  description = "The location for resources"
  default     = "US"
}

variable "default_network_regions" {
  type    = list(string)
  default = [
    "asia-east2",
    "asia-southeast2",
    "us-east5",
    "europe-west8",
    "europe-west3",
    "europe-west9",
    "me-central1",
    "asia-south2",
    "asia-northeast3",
    "australia-southeast1",
    "asia-south1",
    "northamerica-south1",
    "me-west1",
    "asia-northeast2",
    "europe-west2",
    "asia-northeast1",
    "me-central2",
    "northamerica-northeast1",
    "southamerica-west1",
    "europe-west6",
    "australia-southeast2",
    "europe-west12",
    "us-south1",
    "europe-central2",
    "europe-west4",
    "europe-west10",
    "asia-southeast1",
    "asia-east1",
    "us-west1",
    "europe-west1",
    "northamerica-northeast1",
    "europe-north1",
    "africa-south1",
    "southamerica-east1",
    "us-west4",
    "us-west3",
    "us-east4",
    "us-central1",
    "us-west2",
    "europe-southwest1",
    "us-east1"
  ]
  description = "Regions where default subnet flow logs should be enabled"
}

variable "gcs_buckets_uniform_access" {
  type = list(string)
  default = [
    "aviato-game-fight-rvxirf.appspot.com",
    "aviato-game-fight-rvxirf_bucket",
    "staging.aviato-game-fight-rvxirf.appspot.com",
  ]
  description = "List of GCS bucket names for uniform bucket level access"
}

variable "default_vpc_name" {
  type        = string
  description = "Name of the default VPC network"
  default     = "default"
}

variable "default_ssh_allowed_sources" {
  type        = list(string)
  description = "The allowed source ranges for SSH access.  Modify this to restrict SSH access to specific networks."
  default     = []
}

variable "default_rdp_allowed_sources" {
  type        = list(string)
  description = "The allowed source ranges for RDP access.  Modify this to restrict RDP access to specific networks."
  default     = []
}

variable "logging_bucket" {
  type        = string
  description = "The name of the GCS bucket to store logs"
  default     = "aviato-game-fight-rvxirf-logs"
}

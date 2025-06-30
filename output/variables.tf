variable "project_id" {
  type        = string
  description = "The ID of the project in which to provision resources."
  default     = "aviato-game-fight-rvxirf"
}

variable "region" {
  type        = string
  description = "The region in which to provision resources."
  default     = "us-central1"
}

variable "default_subnets" {
  type = list(string)
  default = [
    "africa-south1",
    "southamerica-west1",
    "us-west4",
    "me-central2",
    "asia-east2",
    "asia-northeast1",
    "asia-south2",
    "asia-northeast3",
    "us-south1",
    "australia-southeast1",
    "us-east4",
    "us-west3",
    "asia-southeast1",
    "europe-southwest1",
    "asia-east1",
    "europe-north2",
    "australia-southeast2",
    "northamerica-northeast2",
    "asia-southeast2",
    "northamerica-northeast1",
    "asia-south1",
    "europe-west6",
    "europe-west1",
    "southamerica-east1",
    "asia-northeast2",
    "europe-north1",
    "us-east5",
    "us-west2",
    "us-west1",
    "europe-west10",
    "us-central1",
    "northamerica-south1",
    "europe-west4",
    "europe-west9",
    "europe-west2",
    "europe-west12",
    "europe-west8",
    "me-central1",
    "europe-west3",
    "us-east1",
    "europe-central2",
    "me-west1"
  ]
}

variable "api_key_rotation_days" {
  type        = number
  description = "The number of days after which API keys should be rotated."
  default     = 90
}

variable "rdp_ssh_allowed_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed for RDP and SSH access.  Restrict to your trusted networks."
  default     = ["10.0.0.0/8"]
}

variable "log_export_bucket" {
  type        = string
  description = "Bucket to store the exported logs"
  default = "aviato-game-fight-rvxirf-logs"
}

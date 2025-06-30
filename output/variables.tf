variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = "aviato-game-fight-rvxirf"
}

variable "location" {
  type        = string
  description = "The GCP region"
  default     = "australia-southeast1"
}

variable "default_regions" {
  type = list(string)
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
    "europe-north2",
    "africa-south1",
    "europe-north1",
    "southamerica-east1",
    "us-west4",
    "us-west3",
    "us-east4",
    "us-central1",
    "us-west2",
    "europe-southwest1",
    "us-east1",
  ]
}

variable "trusted_ip_ranges" {
  type        = list(string)
  description = "List of trusted IP ranges for SSH and RDP access"
  default     = ["35.235.240.0/20"]
}

variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = "aviato-game-fight-rvxirf"
}

variable "location" {
  type        = string
  description = "The location for resources"
  default     = "US"
}

variable "regions" {
  type    = list(string)
  default = [
    "us-east4",
    "us-west1",
    "asia-south2",
    "me-west1",
    "us-east1",
    "asia-east1",
    "asia-northeast2",
    "us-south1",
    "europe-west1",
    "australia-southeast1",
    "me-central2",
    "australia-southeast2",
    "europe-north1",
    "asia-east2",
    "us-east5",
    "asia-southeast2",
    "northamerica-northeast2",
    "us-west4",
    "southamerica-east1",
    "europe-west12",
    "us-west3",
    "asia-south1",
    "me-central1",
    "europe-west6",
    "europe-north2",
    "europe-west10",
    "europe-west3",
    "europe-southwest1",
    "asia-northeast1",
    "asia-northeast3",
    "asia-southeast1",
    "europe-west4",
    "europe-central2",
    "us-west2",
    "us-central1",
    "northamerica-northeast1",
    "africa-south1",
    "southamerica-west1",
    "europe-west8",
    "europe-west9"
  ]
  description = "List of regions to enable flow logs"
}

variable "bucket_names" {
  type = list(string)
  default = [
    "aviato-game-fight-rvxirf.appspot.com",
    "aviato-game-fight-rvxirf_bucket",
    "staging.aviato-game-fight-rvxirf.appspot.com"
  ]
  description = "List of bucket names to apply uniform bucket level access"
}

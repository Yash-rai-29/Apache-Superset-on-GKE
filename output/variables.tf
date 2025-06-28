variable "project_id" {
  type        = string
  description = "The GCP project ID."
  default     = "aviato-game-fight-rvxirf"
}

variable "regions" {
  type    = list(string)
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
    "europe-west3"
  ]
  description = "List of regions."
}

variable "api_keys" {
  type    = list(string)
  default = []
  description = "List of API keys."
}

variable "bucket_names" {
  type    = list(string)
  default = [
    "aviato-game-fight-rvxirf.appspot.com",
    "aviato-game-fight-rvxirf_bucket",
    "staging.aviato-game-fight-rvxirf.appspot.com"
  ]
  description = "List of bucket names."
}

variable "service_accounts" {
  type = list(string)
  default = [
    "twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
    "aviato-game-fight-rvxirf@appspot.gserviceaccount.com",
    "30647320905-compute@developer.gserviceaccount.com",
    "firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  ]
  description = "List of service accounts"
}

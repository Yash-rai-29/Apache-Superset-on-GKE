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

variable "default_network_regions" {
  type = list(string)
  default = [
    "asia-east1",
    "asia-east2",
    "asia-northeast1",
    "asia-northeast2",
    "asia-northeast3",
    "asia-south1",
    "asia-south2",
    "asia-southeast1",
    "asia-southeast2",
    "australia-southeast1",
    "australia-southeast2",
    "europe-central2",
    "europe-north1",
    "europe-north2",
    "europe-southwest1",
    "europe-west1",
    "europe-west2",
    "europe-west3",
    "europe-west4",
    "europe-west6",
    "europe-west8",
    "europe-west9",
    "europe-west10",
    "europe-west12",
    "me-central1",
    "me-central2",
    "me-west1",
    "northamerica-northeast1",
    "northamerica-northeast2",
    "northamerica-south1",
    "southamerica-east1",
    "southamerica-west1",
    "us-central1",
    "us-east1",
    "us-east4",
    "us-south1",
    "us-west1",
    "us-west2",
    "us-west3",
    "us-west4"
  ]
  description = "List of regions where default subnets exist."
}

variable "bucket_names" {
  type = list(string)
  default = [
    "aviato-game-fight-rvxirf.appspot.com",
    "aviato-game-fight-rvxirf_bucket",
    "staging.aviato-game-fight-rvxirf.appspot.com"
  ]
  description = "List of cloud storage bucket names"
}

variable "service_account_names" {
  type = list(string)
  default = [
    "twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
    "aviato-game-fight-rvxirf@appspot.gserviceaccount.com",
    "30647320905-compute@developer.gserviceaccount.com",
    "firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  ]
  description = "List of service account names"
}

variable "iam_member" {
  type = string
  default = "user:manan@aviato.consulting"
  description = "IAM member to be checked for separation of duties"
}

variable "user_managed_key_ids" {
  type = list(string)
  default = [
    "7714427bf74150a669726df43977cba4cdcb8755",
    "0d04dce2d68fec2717be85cfed6a26c8d1a29096"
  ]
  description = "List of user managed key ids"
}

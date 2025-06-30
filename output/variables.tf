variable "project_id" {
  type        = string
  description = "The ID of the project"
  default     = "aviato-game-fight-rvxirf"
}

variable "default_regions" {
  type    = list(string)
  default = ["asia-east2", "asia-southeast2", "us-east5", "europe-west8", "europe-west3", "europe-west9", "me-central1", "asia-south2", "asia-northeast3", "australia-southeast1", "asia-south1", "northamerica-south1", "me-west1", "asia-northeast2", "europe-west2", "asia-northeast1", "me-central2", "northamerica-northeast1", "southamerica-west1", "europe-west6", "australia-southeast2", "europe-west12", "us-south1", "europe-central2", "europe-west4", "europe-west10", "asia-southeast1", "asia-east1", "us-west1", "europe-west1", "northamerica-northeast1", "europe-north1", "africa-south1", "europe-north1", "southamerica-east1", "us-west4", "us-west3", "us-east4", "us-central1", "us-west2", "europe-southwest1", "us-east1"]
  description = "List of regions where default subnets need flow logs enabled"
}

variable "bucket_names" {
  type    = list(string)
  default = ["aviato-game-fight-rvxirf.appspot.com", "aviato-game-fight-rvxirf_bucket", "staging.aviato-game-fight-rvxirf.appspot.com"]
  description = "List of bucket names"
}

variable "authorized_networks" {
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description = "List of authorized networks"
}

variable "key_deletion_days" {
  type        = number
  description = "Number of days after which to delete user managed keys"
  default     = 7
}

variable "location" {
  type    = string
  default = "US"
}

variable "multiregion_locations" {
  type    = list(string)
  default = ["AUSTRALIA-SOUTHEAST1", "US"]
}

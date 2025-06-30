variable "project_id" {
  type        = string
  description = "The ID of the project"
  default     = "aviato-game-fight-rvxirf"
}

variable "region" {
  type        = string
  description = "The region to deploy resources"
  default     = "us-central1"
}

variable "default_ssh_source_ranges" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
  description = "Source IP ranges for SSH access"
}

variable "default_rdp_source_ranges" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
  description = "Source IP ranges for RDP access"
}

variable "bucket_names" {
  type = list(string)
  default = [
    "aviato-game-fight-rvxirf.appspot.com",
    "aviato-game-fight-rvxirf_bucket",
    "staging.aviato-game-fight-rvxirf.appspot.com"
  ]
  description = "List of bucket names to enforce uniform bucket-level access"
}

variable "default_subnet_regions" {
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
    "europe-north1",
    "africa-south1",
    "southamerica-east1",
    "us-west4",
    "us-west3",
    "us-east4",
    "us-central1",
    "us-west2",
    "europe-southwest1",
    "us-east1",
    "northamerica-northeast1"
  ]
  description = "List of regions where default subnets exist"
}

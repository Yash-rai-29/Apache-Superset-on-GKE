variable "project_id" {
  type        = string
  description = "The ID of the project"
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
    "europe-west3",
    "us-east1",
    "europe-central2",
    "me-west1"
  ]
  description = "List of regions to configure VPC flow logs."
}

variable "default_network_name" {
  type        = string
  description = "The name of the default network."
  default     = "default"
}

variable "default_allow_ssh_firewall_rule_name" {
  type        = string
  description = "The name of the default allow SSH firewall rule."
  default     = "default-allow-ssh"
}

variable "default_allow_rdp_firewall_rule_name" {
  type        = string
  description = "The name of the default allow RDP firewall rule."
  default     = "default-allow-rdp"
}

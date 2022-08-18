variable "credentials_file_path" {
  description = "path to the gce credentials file"
  type = string
}
variable "projectid" {
  description = "general projectid"
  type = string
}
variable "state_bucket" {
  description = "Bucket where TF state will be saved"
  type = string
}

variable "state_project" {
  description = "ProjectID, it should exist in GCP"
  type = string
}

variable "state_bucket_prefix" {
  description = "Prefix to be used for TF to store TF state."
  type = string
}

variable "zone" {
  description = "zone"
  default = "us-central1-c"
  type = string
}

variable "region" {
  description = "region"
  default = "us-central1"
  type = string
}


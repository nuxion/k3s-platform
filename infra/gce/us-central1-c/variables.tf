variable "project" {
  description = "gce project id"
  type = string
}

variable "base_path" {
  description = "base_path project"
  type = string
}

variable "cluster_name" {
  description = "cluster name"
  type = string
  default = "default"
}

variable "credentials_file_path" {
 description = "Google Cloud service credential file"
 type = string
 default = "~/.ssh/gce/"
}

# variable "public_key_path" {
#     description = "Pub key of op user"
#     type = string
# }

variable "zone" {
  description = "zone"
  type = string
  default = "us-central1-c"
}


variable "location" {
  description = "location"
  type = string
  default = "us-central1"
}

variable "k3s_machine_type" {
  description = "Machine type for k3s server"
  type = string
  default = "nd-standard-1"
}

variable "k3s_boot_type" {
  description = "Machine type for k3s server"
  type = string
  default = "pd-balanced"
}

variable "k3s_boot_size" {
  description = "Machine type for k3s server"
  type = string
  default = "10"
}


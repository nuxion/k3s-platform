variable "credentials_file_path" {
  description = "path to the gce credentials file"
  type = string
}
variable "projectid" {
  description = "general projectid"
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

variable "k3s-cloudconfig" {
  description = "cloud config yaml file"
  default = "files/k3s-cloud-config.yaml"
  type = string
}




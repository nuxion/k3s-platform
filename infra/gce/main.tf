provider "google" {
  # region      = "${var.region}"
  project     = "${var.projectid}"
  credentials = "${file("${var.credentials_file_path}")}"
}

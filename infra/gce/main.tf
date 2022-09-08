provider "google" {
  # region      = "${var.region}"
  project     = "${var.projectid}"
  credentials = "${file("${var.credentials_file_path}")}"
}

# resource "google_service_account" "default" {
#   account_id   = "service-account-id" # which param is this?
#   display_name = "Service Account"
# }

# resource "google_compute_disk" "registry_disk" {
#   name  = "registry"
#   type  = "pd-standard"
#   zone  = var.zone
#   # image = "debian-9-stretch-v20200805"
#   labels = {
#     service = "registry"
#   }
#   size = 10
#   physical_block_size_bytes = 4096
# }

resource "google_compute_instance_template" "k3s-main" {
  name        = "${var.k3s_main_name}"
  description = "K3s main node provisioning"

  tags = ["k3s", "k3s-main"]

  labels = {
    env = "${var.k3s_lbl_env}"
    cluster = "${var.k3s_lbl_cluster}"
  }

  instance_description = "K3S main instance"
  machine_type         = "${var.k3s_machine_type}"
  zone = "${var.k3s_zone}"
  can_ip_forward       = true 

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    # source_image      = "debian-cloud/debian-11"
    source_image      = "${var.k3s_boot_image}"

    auto_delete       = true
    boot              = true
    initialize_params {
      size = "${var.k3s_boot_size}"
      type = "${var.k3s_boot_type}"
    }
    // backup the disk every day
    // resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  # disk {
  #   // Instance Templates reference disks by name, not self link
  #   source      = google_compute_disk.registry_disk.name
  #   auto_delete = false
  #   boot        = false
  #   device_name = "registry"
  # }

  // Use an existing disk resource
  network_interface {
    network = "${var.k3s_network}"
    access_config { # add temporal public ip
      # Ephemeral
      # nat_ip = google_compute_address.core_external_ip.address
    }
  }

  metadata = {
    project = "${var.project}"
    version = "${var.k3s_version}"
    csidisk = "${var.k3s_csidisk}"
    ssh-keys = "${var.operator_user}:${file(var.public_key_path)}"
  }

  provisioner "file" {
    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "${var.operator_user}"
      private_key =   file(var.private_key_path)
      agent       = false
    }
    source = "${.var.base_path}/scripts/gce_k3s_install.sh"
    destination = "/tmp/gce_k3s_install.sh"
  }
  provisioner "remote-exec" {
    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = var.operator_user
      private_key =   "${file("${var.private_key_path}")}"
      agent       = false
    }
    inline = [
        "sudo mv /tmp/wg2.conf /etc/wireguard/wg2.conf",
        "sudo systemctl enable wg-quick@wg2.service",
        "sudo systemctl daemon-reload",
        "sudo systemctl start wg-quick@wg2"
    ]
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "${var.k3s_service_account}@${var.project}.iam.gserviceaccount.com"
    scopes = [""]
  }
}

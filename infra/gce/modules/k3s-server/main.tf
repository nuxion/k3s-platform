resource "google_compute_instance" "k3s_main" {
  name        = "${var.k3s_server_name}"
  description = "K3s main node provisioning"

  tags = ["k3s", "k3s-server", "prod"]

  labels = {
    env = "${var.k3s_lbl_env}"
    cluster = "${var.cluster_name}"
  }

  machine_type         = "${var.k3s_machine_type}"
  zone = "${var.k3s_zone}"
  can_ip_forward       = true 

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  boot_disk {
    # source_image      = "debian-cloud/debian-11"
    auto_delete       = true
    initialize_params {
      size = "${var.k3s_boot_size}"
      image      = "${var.k3s_boot_image}"
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
    clustername = "${var.cluster_name}"
    version = "${var.k3s_version}"
    csidisk = "${var.k3s_csidisk}"
    location = "${var.k3s_location}"
    # ssh-keys = "${var.operator_user}:${file(var.public_key_path)}"
  }

  metadata_startup_script =  "${file("${var.base_path}/scripts/gce_k3s_install.sh")}"

  # provisioner "file" {
  #   connection {
  #     host = self.network_interface.0.access_config.0.nat_ip
  #     type        = "ssh"
  #     user        = "${var.operator_user}"
  #     private_key =   file(var.private_key_path)
  #     agent       = false
  #   }
  #   source = "${var.base_path}/scripts/gce_k3s_install.sh"
  #   destination = "/tmp/gce_k3s_install.sh"
  # }
  # provisioner "remote-exec" {
  #   connection {
  #     host = self.network_interface.0.access_config.0.nat_ip
  #     type        = "ssh"
  #     user        = var.operator_user
  #     private_key =   "${file("${var.private_key_path}")}"
  #     agent       = false
  #   }
  #   inline = [
  #       "sudo /tmp/gce_k3s_install.sh",
  #   ]
  # }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "${var.k3s_service_account}@${var.project}.iam.gserviceaccount.com"
    scopes = ["compute-ro","storage-full"]
  }
}

resource "google_dns_record_set" "kube_api" {
  name = "k3s.${var.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = [google_compute_instance.k3s_main.network_interface[0].network_ip]
}

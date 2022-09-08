resource "google_compute_instance_template" "agent_cpu_tpl" {
  name        = "${var.tpl_name}"
  description = "${var.tpl_description}"

  tags = var.network_tags

  labels = {
    env = "${var.label_env}"
    cluster = "${var.cluster_name}"
  }

  instance_description = "k3s cpu agent"
  machine_type         = "${var.cpu_machine_type}"
  can_ip_forward       = true

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image      = "${var.cpu_boot_image}"
    auto_delete       = true
    boot              = true
    disk_type = "${var.cpu_boot_type}"
    disk_size_gb =  "${var.cpu_boot_size}"

    // backup the disk every day
    // resource_policies = [google_compute_resource_policy.daily_backup.id]
  }


  network_interface {
    network = "${var.k3s_network}"
    access_config {
    }
  }

  metadata = {
    project = "${var.project}"
    clustername = "${var.cluster_name}"
    version = "${var.k3s_version}"
    location = "${var.k3s_location}"
    server = "${var.k3s_url}"
    # ssh-keys = "${var.operator_user}:${file(var.public_key_path)}"
  }

  metadata_startup_script =  "${file("${var.base_path}/scripts/gce_k3s_node_startup.sh")}"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "${var.k3s_service_account}@${var.project}.iam.gserviceaccount.com"
    scopes = var.k3s_scopes
  }
}

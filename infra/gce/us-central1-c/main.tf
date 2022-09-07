provider "google" {
  # region      = "${var.region}"
  project     = "${var.project}"
  credentials = "${file("${var.credentials_file_path}")}"
}

terraform {
  backend "gcs" {
  }
}

resource "google_artifact_registry_repository" "kube_repo" {
  location      = "${var.location}"
  repository_id = "repo"
  description   = "Docker repository"
  format        = "DOCKER"
  project = "${var.project}"
}

resource "google_compute_network" "net_prod" {
  name                    = "prod"
  project = "${var.project}"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "firewall_prod_ext" {
  name    = "prod-external"
  network = google_compute_network.net_prod.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22", "52112"]
  }
  allow {
    protocol = "udp"
    ports    = ["52112"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_prod_int" {
  name    = "prod-internal"
  network = google_compute_network.net_prod.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "7946", "5000", "7373", "52112",
		"6443", "10250", "3000"]
  }

  allow {
    protocol = "udp"
    ports    = ["7946", "52112", "8472"]
  }

  source_tags = ["k3s", "prod"]
  # target_tags = ["prod-internal", "sandboxdefault"]
}

resource "google_dns_managed_zone" "infra_zone" {
  name        = "priv-dns"
  dns_name    = "${var.zone}.cloud."
  description = "Infra private zone"
  project = "${var.project}"
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.net_prod.id
    }
    # networks {
    #  network_url = module.sandbox.net_id
    # }
  }
  depends_on = [
    google_compute_network.net_prod
  ]
}

module "k3s-server" {
  source = "../modules/k3s-server"
  k3s_server_name = "k3s-server"
  base_path = "${var.base_path}"
  k3s_zone = "${var.zone}"
  k3s_location = "${var.location}"
  k3s_network = google_compute_network.net_prod.self_link
  cluster_name = "${var.cluster_name}"
  k3s_machine_type = "${var.k3s_machine_type}"
  k3s_boot_size = "${var.k3s_boot_size}"
  k3s_boot_type = "${var.k3s_boot_type}"
  dns_name = "${google_dns_managed_zone.infra_zone.dns_name}"
  dns_zone_name = google_dns_managed_zone.infra_zone.name
  project = "${var.project}"
}

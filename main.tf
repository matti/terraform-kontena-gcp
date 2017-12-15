module "kontena_node_ignition" {
  source = "github.com/kontena/kontena-terraform-modules/modules/node-ignition"

  master_uri  = "wss://TODO-TODO-123.platforms.us-east-1.kontena.cloud"
  grid_token  = "TODOTODOTODOTODO=="
  docker_opts = "--label provider=gcp --label region=$$REGION --label az=$$ZONE"

  dns_server            = "169.254.169.254" # Google's DNS
  overlay_version       = "overlay"         # or overlay2
  peer_interface        = "ens4v1"
  main_interface_prefix = "ens4v"

  authorized_keys_core = [
    "ssh-rsa TODOTODO....",
  ]
}

data "google_compute_image" "coreos_stable" {
  family  = "coreos-stable"
  project = "coreos-cloud"
}

module "gci_nodes" {
  source = "github.com/matti/terraform-google-compute-instance"

  amount      = 3
  region      = "us-east1"
  name_prefix = "test"

  # Can be changed without destroying the disk
  machine_type = "custom-2-2048"
  disk_size    = 32
  disk_image   = "${data.google_compute_image.coreos_stable.self_link}"
  user_data    = "${module.kontena_node_ignition.rendered}"
}

output "ips" {
  value = "${module.gci_nodes.addresses}"
}

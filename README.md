# Wireguard service module for terraform

## Interfaces

### Input variables

* count - count of connections
* connections - public ips where applied
* private_ips - ips for wireguard communication
* vpn_interface - wireguard interface name (default: wg0)
* vpn_port - wireguard port (default: 51820)
* vpn_cidr - vpn cidr (default: 172.16.10.0/24)
* overlay_cidr - overlay cidr

### Output variables

* public_ips - public ips of instances/servers
* vpn_ips - wireguard/vpn ips of instances/servers
* vpn_interface_unit - wireguard systemd unit name (example: wg-quick@wg0.service)
* overlay_route_unit - network route systemd unit name (example: wg0-network-route.service)
* vpn_interface - wireguard interface name (example: wg0)
* vpn_port - wireguard port
* network_cidr - netowrk cidr
* vpn_cidr - vpn cidr


## Usage with official Hetzner Cloud Provider

* read more at https://www.terraform.io/docs/providers/hcloud/

```
# Set the variable value in *.tfvars file
# or using -var="hcloud_token=..." CLI option
variable "hcloud_token" {}
variable "count" {
  default = "3"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

# Create a server
resource "hcloud_server" "web" {
  count       = "${var.count}"
  name        = "${format("%s-%02d", "web", count.index + 1)}"
  image       = "ubuntu-16.04"
  server_type = "cx11"
  ssh_keys    = ["dev"]
}

module "wireguard" {
  source = "git::https://github.com/suquant/tf_wireguard.git"

  count         = "${var.count}"
  connections   = "${hcloud_server.web.*.ipv4_address}"
  private_ips   = "${hcloud_server.web.*.ipv4_address}"
  overlay_cidr  = "10.10.10.0/24"
}
```

## Usage with tf_hcloud provider

* read more at (https://github.com/suquant/tf_hcloud)
* based on official Hetzner Cloud Provider (https://www.terraform.io/docs/providers/hcloud/)

```
variable "token" {}
variable "hosts" {
  default = 3
}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = "git::https://github.com/suquant/tf_hcloud.git"

  count = "${var.hosts}"
}

module "wireguard" {
  source = "git::https://github.com/suquant/tf_wireguard.git"

  count         = "${var.hosts}"
  connections   = "${module.provider.public_ips}"
  private_ips   = "${module.provider.private_ips}"
  overlay_cidr  = "10.10.10.0/24"
}
```

In case of change host's count, machines will be reconfigured without restarting whole interface(s).

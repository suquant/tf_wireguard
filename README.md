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


## Example

```
variable "token" {}
variable "hosts" {
  default = 3
}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = "git::https://github.com/suquant/tf_hcloud.git?ref=v1.1.0"

  count = "${var.hosts}"
}

module "wireguard" {
  source = "git::https://github.com/suquant/tf_wireguard.git?ref=v1.1.0"

  count         = "${var.hosts}"
  connections   = "${module.provider.public_ips}"
  private_ips   = "${module.provider.private_ips}"
  overlay_cidr  = "10.10.10.0/24"
}
```

In case of change host's count, machines will be reconfigured without restarting whole interface(s).

# Wireguard service module for terraform

## Key features

* Scale hosts without restart of whole interface

## Interfaces

### Input variables

* count - count of connections
* connections - public ips where applied
* private_ips - ips for wireguard communication
* interface - wireguard interface name (default: wg0)
* port - wireguard port (default: 51820)
* network_cidr - network cidr (default: 10.0.1.0/24)
* keys_dir - local directory where wireguard private keys will be stored (default: .wgkeys)

### Output variables

* public_ips - public ips of instances/servers
* ips - wireguard/vpn ips of instances/servers
* systemd_unit - wireguard systemd unit name (example: wg-quick@wg0.service)
* network_route_systemd_unit - network route systemd unit name (example: wg0-network-route.service)
* interface - wireguard interface name (example: wg0)
* port - wireguard port
* network_cidr - netowrk cidr


## Example

```
variable "token" {}
variable "hosts" {
  default = 2
}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = "git::https://github.com/suquant/tf_hcloud.git?ref=v1.0.0"

  count = "${var.hosts}"
  token = "${var.token}"
}

module "wireguard" {
  source = "git::https://github.com/suquant/tf_wireguard.git?ref=v1.0.0"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
  private_ips = "${module.provider.private_ips}"
}
```

In case of change host's count, machines will be reconfigured without restarting whole interface(s).

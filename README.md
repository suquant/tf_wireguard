# Wireguard service module for terraform

## Key features

* Scale hosts without restart of whole interface

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
  source = ".."

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
  private_ips = "${module.provider.private_ips}"
}
```

In case of change host's count, machines will be reconfigured without restarting whole interface(s).

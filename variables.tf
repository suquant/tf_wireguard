variable "count" {}

variable "connections" {
  type = "list"
}

variable "private_ips" {
  type = "list"
}

variable "interface" {
  default = "wg0"
}

variable "port" {
  default = "51820"
}

variable "network_cidr" {
  default = "10.0.1.0/24"
}

variable "keys_dir" {
  default = ".wgkeys"
}
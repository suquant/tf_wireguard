output "public_ips" {
  value = "${var.connections}"

  depends_on = ["null_resource.wireguard"]
}

output "ips" {
  value      = "${data.template_file.ips.*.rendered}"

  depends_on = ["null_resource.wireguard"]
}

output "systemd_unit" {
  value      = "${local.systemd_unit}"

  depends_on = ["null_resource.wireguard"]
}

output "network_route_systemd_unit" {
  value      = "${local.network_route_systemd_unit}"

  depends_on = ["null_resource.wireguard"]
}

output "interface" {
  value = "${var.interface}"

  depends_on = ["null_resource.wireguard"]
}

output "port" {
  value = "${var.port}"

  depends_on = ["null_resource.wireguard"]
}

output "network_cidr" {
  value = "${var.network_cidr}"

  depends_on = ["null_resource.wireguard"]
}
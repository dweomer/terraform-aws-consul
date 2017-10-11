output "cidr_blocks" {
  value = ["${data.null_data_source.network.*.outputs.cidr}"]
}

output "availability_zones" {
  value = ["${formatlist("%s%s", var.region, var.zones[var.region])}"]
}

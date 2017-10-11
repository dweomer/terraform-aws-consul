data "null_data_source" "network" {
  count = "${length(var.zones[var.region])}"

  inputs {
    cidr = "${cidrsubnet(var.supernet, var.subnet_newbits, count.index + var.subnet_netnum_offset)}"
  }
}

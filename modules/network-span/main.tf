data "null_data_source" "span" {
  count = "${length(var.zones[var.region])}"

  inputs {
    cidr = "${cidrsubnet(var.supernet_cidr, var.subnet_newbits, count.index + var.subnet_netnum_offset)}"
  }
}

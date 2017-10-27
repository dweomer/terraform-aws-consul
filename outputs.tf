output "consul_datacenter" {
  value = "${local.env["CONSUL_DATACENTER"]}"
}

output "consul_domain" {
  value = "${local.env["CONSUL_DOMAIN"]}"
}

output "consul_lan_discovery" {
  value = {
    key   = "${module.tag_consul_lan_discovery.key}"
    value = "${module.tag_consul_lan_discovery.value}"
  }
}

output "instance_ami" {
  value = {
    image_architecture   = "${data.aws_ami.rancher_os.architecture}"
    image_id             = "${data.aws_ami.rancher_os.image_id}"
    image_name           = "${data.aws_ami.rancher_os.name}"
    image_virtualization = "${data.aws_ami.rancher_os.virtualization_type}"
    owner_id             = "${data.aws_ami.rancher_os.owner_id}"
    root_device_name     = "${data.aws_ami.rancher_os.root_device_name}"
    root_device_type     = "${data.aws_ami.rancher_os.root_device_type}"
  }
}

output "instance_profile_name" {
  value = "${module.instance_profile.name}"
}

output "instance_profile_role" {
  value = "${module.instance_profile.role}"
}

output "nat_eip_id" {
  value = "${element(module.supernet.nat_ids,0)}"
}

output "nat_eip_public_ip" {
  value = "${element(module.supernet.nat_public_ips,0)}"
}

output "nat_gateway_id" {
  value = "${element(module.supernet.natgw_ids,0)}"
}

output "private_subnet_cidr_blocks" {
  value = ["${module.net_private.cidr_blocks}"]
}

output "private_subnet_ids" {
  value = ["${module.supernet.private_subnets}"]
}

output "public_subnet_cidr_blocks" {
  value = ["${module.net_public.cidr_blocks}"]
}

output "public_subnet_ids" {
  value = ["${module.supernet.public_subnets}"]
}

output "vpc_cidr_block" {
  value = "${module.supernet.vpc_cidr_block}"
}

output "vpc_id" {
  value = "${module.supernet.vpc_id}"
}

output "vpc_name" {
  value = "${lower(module.app_labels.name)}"
}

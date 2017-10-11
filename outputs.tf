output "vpc_id" {
  value = "${module.supernet.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.supernet.vpc_cidr_block}"
}

output "private_subnet_ids" {
  value = ["${module.supernet.private_subnets}"]
}

output "private_subnet_cidr_blocks" {
  value = ["${module.net_private.cidr_blocks}"]
}

output "public_subnet_ids" {
  value = ["${module.supernet.public_subnets}"]
}

output "public_subnet_cidr_blocks" {
  value = ["${module.net_public.cidr_blocks}"]
}

output "instance_ami" {
  value = {
    image_id             = "${data.aws_ami.rancher_os.image_id}"
    image_name           = "${data.aws_ami.rancher_os.name}"
    image_architecture   = "${data.aws_ami.rancher_os.architecture}"
    image_virtualization = "${data.aws_ami.rancher_os.virtualization_type}"
    owner_id             = "${data.aws_ami.rancher_os.owner_id}"
    root_device_name     = "${data.aws_ami.rancher_os.root_device_name}"
    root_device_type     = "${data.aws_ami.rancher_os.root_device_type}"
  }
}

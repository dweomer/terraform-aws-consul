output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.network.vpc_cidr_block}"
}

output "private_subnet_ids" {
  value = ["${module.network.private_subnets}"]
}

output "private_subnet_cidr_blocks" {
  value = ["${data.null_data_source.subnet_private.*.outputs.cidr}"]
}

output "public_subnet_ids" {
  value = ["${module.network.public_subnets}"]
}

output "public_subnet_cidr_blocks" {
  value = ["${data.null_data_source.subnet_public.*.outputs.cidr}"]
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

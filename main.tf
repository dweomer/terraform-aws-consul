provider "aws" {
  region = "${var.region}"
}

data null_data_source "env" {
  inputs {
    CONSUL_BRIDGE_ADDR         = "${var.consul_bridge_addr}"
    CONSUL_BRIDGE_HOST         = "${var.consul_bridge_host}"
    CONSUL_BRIDGE_NAME         = "${var.consul_bridge_name}"
    CONSUL_DATACENTER          = "${coalesce(var.consul_datacenter, format("aws-%s", var.region))}"
    CONSUL_DOMAIN              = "${format("%s.%s.%s", lower(var.stage), lower(var.stack), var.domain)}"
    CONSUL_LAN_DISCOVERY_KEY   = "${coalesce(var.CONSUL_LAN_DISCOVERY_key, "Shard")}"
    CONSUL_LAN_DISCOVERY_VALUE = "${coalesce(var.CONSUL_LAN_DISCOVERY_value, format("%s-%s", lower(module.labeling.name), lower(module.vpc.vpc_id)))}"
    CONSUL_VERSION             = "${var.consul_version}"
  }
}

module "labeling" {
  source = "./modules/labeling"

  stack = "${var.stack}"
  stage = "${var.stage}"
}

module "net_private" {
  source = "./modules/networking"

  region = "${var.region}"

  supernet             = "${var.supernet}"
  subnet_newbits       = 6
  subnet_netnum_offset = 0
}

module "net_public" {
  source = "./modules/networking"

  region = "${var.region}"

  supernet             = "${var.supernet}"
  subnet_newbits       = 6
  subnet_netnum_offset = "${length(module.net_private.cidr_blocks)}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = "${var.supernet}"
  name = "${module.labeling.name}"
  tags = "${module.labeling.tags}"
  azs  = ["${module.net_private.availability_zones}"]

  private_subnets = ["${module.net_private.cidr_blocks}"]
  public_subnets  = ["${module.net_public.cidr_blocks}"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support = true

  # enable_dns_hostnames = true

  map_public_ip_on_launch = true
}

data "aws_ami" "rancher_os" {
  most_recent = true

  filter {
    name   = "name"
    values = ["rancheros-*-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["605812595337"] # Rancher Labs
}

module "instance_profile" {
  source = "./modules/instance-profile"

  name_prefix = "${lower(module.labeling.name)}-consul-"
}

resource "aws_key_pair" "consul" {
  key_name_prefix = "${lower(module.labeling.name)}-consul-"
  public_key      = "${file("~/.ssh/id_rsa.pub")}"
}

module "servers" {
  source = "./modules/group"

  name = "${module.labeling.name}"
  role = "server"

  # Launch Configuration
  ssh_key_name         = "${aws_key_pair.consul.key_name}"
  image_id             = "${data.aws_ami.rancher_os.image_id}"
  instance_type        = "${var.instance_type_server}"
  security_groups      = ["${module.vpc.default_security_group_id}"]
  iam_instance_profile = "${module.instance_profile.name}"

  user_data_template = "${file("templates/cloud-config.yml")}"

  user_data_variables = "${merge(
    data.null_data_source.env.outputs,
    map("CONSUL_LOCAL_CONFIG", format("{%s: %s, %s: %s, %s: %s}", jsonencode("server"), "true", jsonencode("ui"), "true", jsonencode("bootstrap_expect"), var.consul_min_servers))
  )}"

  root_block_device = [{
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }]

  # Auto-Scaling Group
  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
  minimum_capacity    = "${var.consul_min_servers}"
  maximum_capacity    = "${var.consul_max_servers}"
  desired_capacity    = "${coalesce(var.consul_desired_servers,var.consul_min_servers)}"

  tags_for_group_and_instances = "${merge(
    module.labeling.tags,
    map(lookup(data.null_data_source.env.outputs, "CONSUL_LAN_DISCOVERY_KEY"), lookup(data.null_data_source.env.outputs, "CONSUL_LAN_DISCOVERY_VALUE"))
  )}"
}

module "clients" {
  source = "./modules/group"

  name = "${module.labeling.name}"
  role = "client"

  # Launch Configuration
  ssh_key_name         = "${aws_key_pair.consul.key_name}"
  image_id             = "${data.aws_ami.rancher_os.image_id}"
  instance_type        = "${var.instance_type_server}"
  security_groups      = ["${module.vpc.default_security_group_id}"]
  iam_instance_profile = "${module.instance_profile.name}"

  user_data_template = "${file("templates/cloud-config.yml")}"

  user_data_variables = "${merge(
    data.null_data_source.env.outputs,
    map("CONSUL_LOCAL_CONFIG", format("{%s: %s, %s: %s}", jsonencode("server"), "false", jsonencode("ui"), "true"))
  )}"

  root_block_device = [{
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }]

  # Auto-Scaling Group
  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
  minimum_capacity    = "${var.consul_min_servers}"
  maximum_capacity    = "${var.consul_max_servers}"
  desired_capacity    = "${coalesce(var.consul_desired_servers,var.consul_min_servers)}"

  tags_for_group_and_instances = "${merge(
    module.labeling.tags,
    map(lookup(data.null_data_source.env.outputs, "CONSUL_LAN_DISCOVERY_KEY"), lookup(data.null_data_source.env.outputs, "CONSUL_LAN_DISCOVERY_VALUE"))
  )}"
}

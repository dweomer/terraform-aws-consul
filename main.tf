provider "aws" {
  region = "${var.region}"
}

data "null_data_source" "subnet_private" {
  count = "${length(var.zones[var.region])}"

  inputs {
    cidr = "${cidrsubnet(var.cidr_block, var.subnet_bits, count.index)}"
  }
}

data "null_data_source" "subnet_public" {
  count = "${length(var.zones[var.region])}"

  inputs {
    cidr = "${cidrsubnet(var.cidr_block, var.subnet_bits, count.index + length(var.zones[var.region]))}"
  }
}

data null_data_source "env" {
  inputs {
    CONSUL_BRIDGE_ADDR      = "${var.consul_bridge_addr}"
    CONSUL_BRIDGE_HOST      = "${var.consul_bridge_host}"
    CONSUL_BRIDGE_NAME      = "${var.consul_bridge_name}"
    CONSUL_DATACENTER       = "${coalesce(var.consul_datacenter, format("aws-%s", var.region))}"
    CONSUL_DOMAIN           = "${format("%s.%s.%s", lower(var.stage), lower(var.stack), var.domain)}"
    CONSUL_RETRY_JOIN_KEY   = "${coalesce(var.consul_retry_join_key, "Shard")}"
    CONSUL_RETRY_JOIN_VALUE = "${coalesce(var.consul_retry_join_value, format("%s-%s-%s", lower(var.stack), lower(var.stage), lower(module.network.vpc_id)))}"
    CONSUL_VERSION          = "${var.consul_version}"
  }
}

data null_data_source "tags" {
  inputs {
    Stack = "${title(var.stack)}"
    Stage = "${upper(var.stage)}"
  }
}

module "network" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${format("%s-%s", lower(var.stack), lower(var.stage))}"
  cidr = "${var.cidr_block}"
  tags = "${data.null_data_source.tags.outputs}"
  azs  = ["${formatlist("%s%s", var.region, var.zones[var.region])}"]

  private_subnets = ["${data.null_data_source.subnet_private.*.outputs.cidr}"]
  public_subnets  = ["${data.null_data_source.subnet_public.*.outputs.cidr}"]

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

data "aws_iam_policy_document" "consul_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "consul_discover" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "consul" {
  assume_role_policy = "${data.aws_iam_policy_document.consul_instance.json}"
  name_prefix        = "${lower(var.stack)}-${lower(var.stage)}-consul-"
}

resource "aws_iam_role_policy" "consul" {
  name_prefix = "${lower(var.stack)}-${lower(var.stage)}-consul-"
  role        = "${aws_iam_role.consul.name}"
  policy      = "${data.aws_iam_policy_document.consul_discover.json}"
}

resource "aws_iam_instance_profile" "consul" {
  name_prefix = "${lower(var.stack)}-${lower(var.stage)}-consul-"
  role        = "${aws_iam_role.consul.name}"
}

resource "aws_key_pair" "consul" {
  key_name_prefix = "${lower(var.stack)}-${lower(var.stage)}-consul-"
  public_key      = "${file("~/.ssh/id_rsa.pub")}"
}

data "template_file" "consul_server" {
  template = "${file("templates/cloud-config.yml")}"

  vars = "${merge(
    data.null_data_source.env.outputs,
    map("CONSUL_LOCAL_CONFIG", format("{%s: %s, %s: %s, %s: %s}", jsonencode("server"), "true", jsonencode("ui"), "true", jsonencode("bootstrap_expect"), var.consul_min_servers))
  )}"
}

module "consul_servers" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Launch Configuration
  lc_name              = "${lower(var.stack)}-${lower(var.stage)}-consul-server"
  image_id             = "${data.aws_ami.rancher_os.image_id}"
  instance_type        = "${var.instance_type_server}"
  security_groups      = ["${module.network.default_security_group_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.consul.name}"

  key_name  = "${aws_key_pair.consul.key_name}"
  user_data = "${data.template_file.consul_server.rendered}"

  root_block_device = [{
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }]

  # Auto-Scaling Group
  asg_name            = "${lower(var.stack)}-${lower(var.stage)}-consul-server"
  vpc_zone_identifier = ["${module.network.private_subnets}"]
  health_check_type   = "EC2"
  min_size            = "${var.consul_min_servers}"
  max_size            = "${var.consul_max_servers}"
  desired_capacity    = "${coalesce(var.consul_desired_servers,var.consul_min_servers)}"

  tags = [
    "${map("propagate_at_launch", true, "key", "Stack", "value", lookup(data.null_data_source.tags.outputs, "Stack"))}",
    "${map("propagate_at_launch", true, "key", "Stage", "value", lookup(data.null_data_source.tags.outputs, "Stage"))}",
    "${map("propagate_at_launch", true, "key", lookup(data.null_data_source.env.outputs, "CONSUL_RETRY_JOIN_KEY"), "value", lookup(data.null_data_source.env.outputs, "CONSUL_RETRY_JOIN_VALUE"))}",
  ]
}

data "template_file" "consul_client" {
  template = "${file("templates/cloud-config.yml")}"

  vars = "${merge(
    data.null_data_source.env.outputs,
    map("CONSUL_LOCAL_CONFIG", format("{%s: %s, %s: %s}", jsonencode("server"), "false", jsonencode("ui"), "true"))
  )}"
}

module "consul_clients" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Launch Configuration
  lc_name              = "${lower(var.stack)}-${lower(var.stage)}-consul-client"
  image_id             = "${data.aws_ami.rancher_os.image_id}"
  instance_type        = "${var.instance_type_client}"
  security_groups      = ["${module.network.default_security_group_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.consul.name}"

  key_name  = "${aws_key_pair.consul.key_name}"
  user_data = "${data.template_file.consul_client.rendered}"

  root_block_device = [{
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }]

  # Auto-Scaling Group
  asg_name            = "${lower(var.stack)}-${lower(var.stage)}-consul-client"
  vpc_zone_identifier = ["${module.network.public_subnets}"]
  health_check_type   = "EC2"
  min_size            = "${var.consul_min_clients}"
  max_size            = "${var.consul_max_clients}"
  desired_capacity    = "${coalesce(var.consul_desired_clients,var.consul_min_clients)}"

  tags = [
    "${map("propagate_at_launch", true, "key", "Stack", "value", lookup(data.null_data_source.tags.outputs, "Stack"))}",
    "${map("propagate_at_launch", true, "key", "Stage", "value", lookup(data.null_data_source.tags.outputs, "Stage"))}",
    "${map("propagate_at_launch", true, "key", lookup(data.null_data_source.env.outputs, "CONSUL_RETRY_JOIN_KEY"), "value", lookup(data.null_data_source.env.outputs, "CONSUL_RETRY_JOIN_VALUE"))}",
  ]
}

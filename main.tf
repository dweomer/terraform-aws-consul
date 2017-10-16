provider "aws" {
  region = "${var.region}"
}

module "net_private" {
  source = "./modules/network-span"

  region = "${var.region}"

  supernet_cidr        = "${var.supernet_cidr}"
  subnet_newbits       = 6
  subnet_netnum_offset = 0
}

module "net_public" {
  source = "./modules/network-span"

  region = "${var.region}"

  supernet_cidr        = "${var.supernet_cidr}"
  subnet_newbits       = 6
  subnet_netnum_offset = "${length(module.net_private.cidr_blocks)}"
}

module "tag_stack" {
  source = "./modules/application-tag"

  key                 = "Stack"
  value               = "${title(var.stack)}"

  propagate_at_launch = true
}

module "tag_stage" {
  source = "./modules/application-tag"

  key                 = "Stage"
  value               = "${upper(var.stage)}"

  propagate_at_launch = true
}

module "app_labels" {
  source    = "./modules/application-labels"
  name_tags = ["${list(module.tag_stack.map, module.tag_stage.map)}"]
}

locals {
  env = {
    CONSUL_BRIDGE_ADDR         = "${cidrhost(var.consul_bridge_cidr,0)}"
    CONSUL_BRIDGE_CIDR         = "${var.consul_bridge_cidr}"
    CONSUL_BRIDGE_HOST         = "${var.consul_bridge_host}"
    CONSUL_BRIDGE_NAME         = "${var.consul_bridge_name}"
    CONSUL_DATACENTER          = "${coalesce(var.consul_datacenter, format("aws-%s", var.region))}"
#    CONSUL_DOMAIN              = "${format("%s.%s.%s", lower(var.stage), lower(var.stack), var.domain)}"
    CONSUL_DOMAIN              = "consul"
    CONSUL_LAN_DISCOVERY_KEY   = "${module.tag_consul_lan_discovery.key}"
    CONSUL_LAN_DISCOVERY_VALUE = "${module.tag_consul_lan_discovery.value}"
    CONSUL_RECURSORS           = "${jsonencode(list(cidrhost(var.supernet_cidr,2)))}"
    CONSUL_VERSION             = "${var.consul_version}"
    DOCKER_BRIDGE_CIDR         = "${var.docker_bridge_cidr}"
    DOCKER_VERSION             = "${var.docker_version}"
    RANCHER_OS_VERSION         = "1.1.0"
  }
}

module "supernet" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = "${var.supernet_cidr}"
  name = "${lower(module.app_labels.name)}"
  tags = "${module.app_labels.simple_tags}"
  azs  = ["${module.net_private.availability_zones}"]

  private_subnets = ["${module.net_private.cidr_blocks}"]
  public_subnets  = ["${module.net_public.cidr_blocks}"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  map_public_ip_on_launch = true
}

resource "aws_default_security_group" "supernet" {
  vpc_id = "${module.supernet.vpc_id}"
  tags   = "${merge(module.app_labels.simple_tags, map("Name", format("%s-default", lower(module.app_labels.name))))}"

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "tag_consul_lan_discovery" {
  source = "./modules/application-tag"

  key                 = "${coalesce(var.consul_lan_discovery_key, "Shard")}"
  value               = "${coalesce(var.consul_lan_discovery_value, format("%s-consul-%s", lower(module.app_labels.name), lower(module.supernet.vpc_id)))}"

  propagate_at_launch = true
}

# passing this to the servers module ought to prevent the group from coming up before the network is fully routed
module "tag_nat_gateway" {
  source = "./modules/application-tag"

  key                 = "${element(module.supernet.natgw_ids, 0)}"
  value               = "${element(module.supernet.nat_ids, 0)}"

  propagate_at_launch = false
}

data "aws_ami" "rancher_os" {
  most_recent = true

  filter {
    name   = "name"
    values = ["rancheros-v${local.env["RANCHER_OS_VERSION"]}-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["605812595337"] # Rancher Labs
}

module "instance_profile" {
  source = "./modules/instance-profile"

  role_name_prefix = "${lower(module.app_labels.name)}-consul-"
}

resource "aws_key_pair" "consul" {
  key_name_prefix = "${lower(module.app_labels.name)}-consul-"
  public_key      = "${file("~/.ssh/id_rsa.pub")}"
}

module "servers" {
  source = "./modules/autoscaling-group"

  name = "${lower(module.app_labels.name)}-consul-server"

  # Launch Configuration
  ssh_key_name         = "${aws_key_pair.consul.key_name}"
  image_id             = "${data.aws_ami.rancher_os.image_id}"
  instance_type        = "${var.instance_type_server}"
  security_groups      = ["${module.supernet.default_security_group_id}"]
  iam_instance_profile = "${module.instance_profile.name}"

  user_data_template = "${file("templates/cloud-config.yml")}"

  user_data_variables = "${merge(
    local.env,
    map("CONSUL_LOCAL_CONFIG", format("{%q : true, %q : true, %q : %s}", "server", "ui", "bootstrap_expect", var.consul_min_servers)),
    map("DOCKER_ENGINE_LABELS", jsonencode(list(
        format("consul.role=%s", "server"),
        format("docker.role=%s", "engine")
    )))
  )}"

  root_block_device = [{
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }]

  # Auto-Scaling Group
  vpc_zone_identifier = ["${module.supernet.private_subnets}"]
  minimum_capacity    = "${var.consul_min_servers}"
  maximum_capacity    = "${var.consul_max_servers}"
  desired_capacity    = "${coalesce(var.consul_desired_servers,var.consul_min_servers)}"

  tags = ["${list(module.tag_stack.map, module.tag_stage.map, module.tag_consul_lan_discovery.map, module.tag_nat_gateway.map)}"]
}

module "clients" {
  source = "./modules/autoscaling-group"

  name = "${lower(module.app_labels.name)}-consul-client"

  # Launch Configuration
  ssh_key_name         = "${aws_key_pair.consul.key_name}"
  image_id             = "${data.aws_ami.rancher_os.image_id}"
  instance_type        = "${var.instance_type_client}"
  security_groups      = ["${module.supernet.default_security_group_id}"]
  iam_instance_profile = "${module.instance_profile.name}"

  user_data_template = "${file("templates/cloud-config.yml")}"

  user_data_variables = "${merge(
    local.env,
    map("CONSUL_LOCAL_CONFIG", format("{%q : false, %q : true}", "server", "ui")),
    map("DOCKER_ENGINE_LABELS", jsonencode(list(
        format("consul.role=%s", "client"),
        format("docker.role=%s", "engine")
    )))
  )}"

  root_block_device = [{
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }]

  # Auto-Scaling Group
  vpc_zone_identifier = ["${module.supernet.public_subnets}"]
  minimum_capacity    = "${var.consul_min_clients}"
  maximum_capacity    = "${var.consul_max_clients}"
  desired_capacity    = "${coalesce(var.consul_desired_clients,var.consul_min_clients)}"

  tags = ["${list(module.tag_stack.map, module.tag_stage.map, module.tag_consul_lan_discovery.map)}"]
}

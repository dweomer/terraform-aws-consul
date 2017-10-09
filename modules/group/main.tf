module "this" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Launch Configuration
  lc_name              = "${var.name}-${var.kind}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${var.security_groups}"]
  iam_instance_profile = "${var.iam_instance_profile}"

  key_name  = "${var.key_name}"
  user_data = "${var.user_data}"

  root_block_device = ["${var.root_block_device}"]

  # Auto-Scaling Group
  asg_name            = "${var.name}-${var.kind}"
  vpc_zone_identifier = ["${var.vpc_zone_identifier}"]
  health_check_type   = "EC2"
  min_size            = "${var.min_size}"
  max_size            = "${var.max_size}"
  desired_capacity    = "${coalesce(var.desired_capacity, var.min_size)}"

  tags = [
    "${map("propagate_at_launch", true, "key", "Stack", "value", lookup(data.null_data_source.tags.outputs, "Stack"))}",
    "${map("propagate_at_launch", true, "key", "Stage", "value", lookup(data.null_data_source.tags.outputs, "Stage"))}",
    "${map("propagate_at_launch", true, "key", lookup(data.null_data_source.env.outputs, "CONSUL_RETRY_JOIN_KEY"), "value", lookup(data.null_data_source.env.outputs, "CONSUL_RETRY_JOIN_VALUE"))}",
  ]
}


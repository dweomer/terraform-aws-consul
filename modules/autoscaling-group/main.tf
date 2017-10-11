data "template_file" "user_data" {
  template = "${var.user_data_template}"

  vars = "${var.user_data_variables}"
}

module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Launch Configuration
  lc_name              = "${format("%s-%s", var.name, var.role)}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${var.security_groups}"]
  iam_instance_profile = "${var.iam_instance_profile}"

  key_name  = "${var.ssh_key_name}"
  user_data = "${data.template_file.user_data.rendered}"

  root_block_device = "${var.root_block_device}"

  # Auto-Scaling Group
  asg_name            = "${format("%s-%s", var.name, var.role)}"
  vpc_zone_identifier = ["${var.vpc_zone_identifier}"]
  health_check_type   = "EC2"
  min_size            = "${var.minimum_capacity}"
  max_size            = "${var.maximum_capacity}"
  desired_capacity    = "${coalesce(var.desired_capacity,var.minimum_capacity)}"

  tags = ["${var.tags}"]
}

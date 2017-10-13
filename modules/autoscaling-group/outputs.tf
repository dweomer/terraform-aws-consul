output "autoscaling_group_arn" {
  value = "${module.autoscaling.this_autoscaling_group_arn}"
}

output "autoscaling_group_id" {
  value = "${module.autoscaling.this_autoscaling_group_id}"
}

output "autoscaling_group_name" {
  value = "${module.autoscaling.this_autoscaling_group_name}"
}

output "autoscaling_group_size" {
  value = {
    desired = "${module.autoscaling.this_autoscaling_group_desired_capacity}"
    minimum = "${module.autoscaling.this_autoscaling_group_min_size}"
    maximum = "${module.autoscaling.this_autoscaling_group_max_size}"
  }
}

output "launch_configuration_id" {
  value = "${module.autoscaling.this_launch_configuration_id}"
}

output "user_data" {
  value = "${data.template_file.user_data.rendered}"
}

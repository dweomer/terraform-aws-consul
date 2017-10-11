output "role" {
  value = "${aws_iam_role.module.id}"
}

output "name" {
  value = "${aws_iam_instance_profile.module.id}"
}

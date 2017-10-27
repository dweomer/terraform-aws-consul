output "zone" {
  value = "${aws_route53_zone.module.zone_id}"
}

output "name" {
  value = "${local.name}"
}

output "nameservers" {
  value = ["${aws_route53_zone.module.name_servers}"]
}

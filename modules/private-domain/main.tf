locals {
  name = "${coalesce(var.name,"example.com")}"
}

resource "aws_route53_zone" "module" {
  name   = "${local.name}"
  tags   = "${var.tags}"
  vpc_id = "${var.vpc_id}"
}

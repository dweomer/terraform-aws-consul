data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "module" {
  description        = "Consul Cluster Auto-Discovery"
  assume_role_policy = "${data.aws_iam_policy_document.assume_ec2.json}"
  name_prefix        = "${var.role_name_prefix}"
}

resource "aws_iam_instance_profile" "module" {
  name_prefix = "${var.role_name_prefix}"
  role        = "${aws_iam_role.module.name}"
}

data "aws_iam_policy_document" "auto_discover_cluster" {
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

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "auto-discover-cluster"
  role   = "${aws_iam_role.module.name}"
  policy = "${data.aws_iam_policy_document.auto_discover_cluster.json}"
}

resource "aws_iam_role_policy" "instance_profile_inline" {
  count  = "${length(var.role_inline_policies)}"
  name   = "${element(keys(var.role_inline_policies), count.index)}"
  role   = "${aws_iam_role.module.name}"
  policy = "${element(values(var.role_inline_policies), count.index)}"
}

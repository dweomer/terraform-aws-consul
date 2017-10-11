data "aws_iam_policy_document" "assume" {
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
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
  name_prefix        = "${var.name_prefix}"
}

resource "aws_iam_instance_profile" "module" {
  name = "${aws_iam_role.module.name}"
  role = "${aws_iam_role.module.name}"
}

data "aws_iam_policy_document" "discover" {
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

resource "aws_iam_role_policy" "discover" {
  name   = "auto-discover-cluster"
  role   = "${aws_iam_role.module.name}"
  policy = "${data.aws_iam_policy_document.discover.json}"
}

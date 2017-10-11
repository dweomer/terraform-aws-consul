data "null_data_source" "name_tags" {
  count = "${length(var.name_tags)}"

  inputs {
    key                 = "${lookup(var.name_tags[count.index], "key")}"
    value               = "${lookup(var.name_tags[count.index], "value")}"
    propagate_at_launch = "${lookup(var.name_tags[count.index], "propagate_at_launch")}"
  }
}

data "null_data_source" "other_tags" {
  count = "${length(var.other_tags)}"

  inputs {
    key                 = "${lookup(var.other_tags[count.index], "key")}"
    value               = "${lookup(var.other_tags[count.index], "value")}"
    propagate_at_launch = "${lookup(var.other_tags[count.index], "propagate_at_launch")}"
  }
}

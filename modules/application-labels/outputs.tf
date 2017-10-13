output "name" {
  value = "${join("-", data.null_data_source.name_tags.*.outputs.value)}"
}

output "simple_tags" {
  value = "${merge(
    zipmap(data.null_data_source.name_tags.*.outputs.key, data.null_data_source.name_tags.*.outputs.value),
    zipmap(data.null_data_source.other_tags.*.outputs.key, data.null_data_source.other_tags.*.outputs.value)
  )}"
}

output "autoscaling_tags" {
  value = "${concat(var.name_tags, var.other_tags)}"
}

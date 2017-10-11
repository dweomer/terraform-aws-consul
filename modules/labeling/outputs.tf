output "tags" {
  value = "${merge(map(),data.null_data_source.application.outputs)}"
}

output "stack" {
  value = "${lookup(data.null_data_source.application.outputs, "Stack")}"
}

output "stage" {
  value = "${lookup(data.null_data_source.application.outputs, "Stage")}"
}

output "name" {
  value = "${format("%s-%s", lookup(data.null_data_source.application.outputs, "Stack"), lookup(data.null_data_source.application.outputs, "Stage"))}"
}

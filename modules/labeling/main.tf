data null_data_source "application" {
  inputs {
    Stack = "${coalesce(title(var.stack), "Unknown")}"
    Stage = "${coalesce(upper(var.stage), "TEST")}"
  }
}

output "map" {
  value = "${local.m}"
}

output "kvp" {
  value = "${map(local.m["key"], local.m["value"])}"
}

output "key" {
  value = "${local.m["key"]}"
}

output "value" {
  value = "${local.m["value"]}"
}

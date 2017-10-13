output "map" {
  value = "${local.tag}"
}

output "kvp" {
  value = "${map(local.tag["key"], local.tag["value"])}"
}

output "key" {
  value = "${local.tag["key"]}"
}

output "value" {
  value = "${local.tag["value"]}"
}

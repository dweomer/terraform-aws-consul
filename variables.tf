variable "consul_bridge_cidr" {
  default = "169.254.127.127/32"
}

variable "consul_bridge_host" {
  default = "consul"
}

variable "consul_bridge_name" {
  default = "consul0"
}

variable "consul_datacenter" {
  default = ""
}

variable "consul_lan_discovery_key" {
  default = ""
}

variable "consul_lan_discovery_value" {
  default = ""
}

variable "consul_min_servers" {
  default = "3"
}

variable "consul_max_servers" {
  default = "3"
}

variable "consul_desired_servers" {
  default = ""
}

variable "consul_min_clients" {
  default = "3"
}

variable "consul_max_clients" {
  default = "3"
}

variable "consul_desired_clients" {
  default = ""
}

variable "consul_version" {
  default = "0.9.3"
}

variable "docker_bridge_cidr" {
  default = "172.16.0.1/16"
}

variable "docker_version" {
  default = "17.06.1-ce"
}

variable "domain" {
  description = "Root Domain Name"
  default     = "example.com"
}

variable "instance_type_server" {
  default = "t2.small"
}

variable "instance_type_client" {
  default = "t2.small"
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "stack" {
  description = "The Stack"
  default     = "Unknown"
}

variable "stage" {
  description = "The Stage"
  default     = "TEST"
}

variable "supernet_cidr" {
  description = "VPC CIDR Block"
  default     = "172.31.0.0/16"
}

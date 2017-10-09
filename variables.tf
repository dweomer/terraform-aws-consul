variable "cidr_block" {
  description = "CIDR Block"
  default     = "172.31.0.0/16"
}

variable "consul_bridge_addr" {
  default = "169.254.127.127"
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

variable "consul_retry_join_key" {
  default = ""
}

variable "consul_retry_join_value" {
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

variable "subnet_bits" {
  description = "Subnet Prefix Bits"
  default     = 6
}

variable "zones" {
  type        = "map"
  description = "Availability Zone Suffixes"

  default = {
    ap-northeast-1 = ["a", "b", "c"]
    ap-northeast-2 = ["a", "c"]
    ap-south-1     = ["a", "b"]
    ap-southeast-1 = ["a", "b"]
    ap-southeast-2 = ["a", "b", "c"]
    ca-central-1   = ["a", "b"]
    eu-central-1   = ["a", "b", "c"]
    eu-west-1      = ["a", "b", "c"]
    eu-west-2      = ["a", "b"]
    sa-east-1      = ["a", "b", "c"]
    us-east-1      = ["a", "b", "c", "d", "e", "f"]
    us-east-2      = ["a", "b", "c"]
    us-west-1      = ["a", "b", "c"]
    us-west-2      = ["a", "b", "c"]
  }
}

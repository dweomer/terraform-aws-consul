variable "region" {
  description = "AWS Region"
}

variable "subnet_newbits" {
  description = "cidrsubnet newbits"
}

variable "subnet_netnum_offset" {
  description = "cidrsubnet netnum offset"
}

variable "supernet" {
  description = "VPC CIDR (aka Supernet)"
}

variable "zones" {
  type        = "map"
  description = "Availability Zone Suffixes per Region"

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

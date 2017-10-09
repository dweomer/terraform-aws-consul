variable "name" {
  description = "The name of the group"
}

variable "kind" {
  description = "The kind of the group"
}

variable "key_name" {

}

variable "iam_instance_profile" {

}

variable "image_id" {

}

variable "instance_type" {

}

variable "max_size" {
  description = "The maximum size of the auto scale group"
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
}

variable "root_block_device" {
  type = "list"
  default = []
}

variable "security_groups" {
  type = "list"
}

variable "tags" {
  type = "list"
  default = []
}

variable "user_data" {

}

variable "vpc_zone_identifier" {
  type = "list"
}


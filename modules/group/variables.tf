variable "name" {
  type        = "string"
  description = "The name of the group"
}

variable "role" {
  type        = "string"
  description = "The role of the group (`server` or `client`)"
}

variable "iam_instance_profile" {
  type        = "string"
  description = ""
}

variable "image_id" {
  type        = "string"
  description = ""
}

variable "instance_type" {
  type        = "string"
  description = ""
}

variable "maximum_capacity" {
  type        = "string"
  description = "The maximum size of the auto scale group"
}

variable "minimum_capacity" {
  type        = "string"
  description = "The minimum size of the auto scale group"
}

variable "desired_capacity" {
  type        = "string"
  description = "The number of Amazon EC2 instances that should be running in the group"
}

variable "tags_for_group_only" {
  type        = "map"
  description = "Tags to apply to the ASG/LC only"
  default     = {}
}

variable "tags_for_group_and_instances" {
  type        = "map"
  description = "Tags to apply to the ASG/LC and instances"
  default     = {}
}

variable "root_block_device" {
  type    = "list"
  default = []
}

variable "security_groups" {
  type        = "list"
  description = ""
}

variable "ssh_key_name" {
  type        = "string"
  description = ""
}

variable "user_data_template" {
  type        = "string"
  description = ""
}

variable "user_data_variables" {
  type        = "map"
  description = ""
}

variable "vpc_zone_identifier" {
  type        = "list"
  description = ""
}

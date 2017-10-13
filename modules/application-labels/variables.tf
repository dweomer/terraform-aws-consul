variable "name_tags" {
  type        = "list"
  description = "ASG-style Tags (values act as name segments)"
  default     = []
}

variable "other_tags" {
  type        = "list"
  description = "ASG-style Tags (not part of the name)"
  default     = []
}

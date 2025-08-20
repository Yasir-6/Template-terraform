
variable "target_group_port" {
  description = "Port for the target group"
  type        = number
}

variable "target_group_health_check_path" {
  description = "Health check path for the target group"
  type        = string
}

variable "target_group_health_check_codes" {
  description = "Expected HTTP response codes for health check"
  type        = string
}

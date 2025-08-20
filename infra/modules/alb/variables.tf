
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

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

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

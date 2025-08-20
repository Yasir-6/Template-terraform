variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "load_balancer_arn" {
  description = "ALB ARN"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "microservices" {
  description = "Microservices configuration"
  type = map(object({
    image  = string
    port   = number
    host   = string
    cpu    = number
    memory = number
    env_variables = optional(map(string), {})
  }))
}
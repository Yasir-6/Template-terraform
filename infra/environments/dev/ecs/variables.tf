
variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the docker image"
  type        = number
}

variable "env_variable_names" {
  description = "List of environment variable names to fetch from Parameter Store"
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "CPU units for the task (1024 = 1 CPU)"
  type        = string
}

variable "memory" {
  description = "Memory for the task (in MiB)"
  type        = string
}

variable "desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 1
}

variable "use_private_subnets" {
  description = "Whether to use private subnets for ECS tasks"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Whether to enable auto scaling for the ECS service"
  type        = bool
  default     = false
}

variable "env_file_arn" {
  description = "ARN of the S3 object containing environment variables"
  type        = string
}


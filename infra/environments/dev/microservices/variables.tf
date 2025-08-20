variable "chat_image" {
  description = "Docker image for Chat service"
  type        = string
  default     = "chat:latest"
}

variable "payment_image" {
  description = "Docker image for Payment service"
  type        = string
  default     = "payment:latest"
}

variable "admin_image" {
  description = "Docker image for Admin service"
  type        = string
  default     = "admin:latest"
}
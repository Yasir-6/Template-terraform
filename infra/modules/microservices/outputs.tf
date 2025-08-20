output "target_group_arns" {
  description = "ARNs of target groups"
  value       = { for k, v in aws_lb_target_group.microservice_target_groups : k => v.arn }
}

output "service_names" {
  description = "Names of ECS services"
  value       = { for k, v in aws_ecs_service.microservice_services : k => v.name }
}

output "task_definition_arns" {
  description = "ARNs of task definitions"
  value       = { for k, v in aws_ecs_task_definition.microservice_tasks : k => v.arn }
}

output "security_group_id" {
  description = "Security group ID for microservices"
  value       = aws_security_group.microservices_sg.id
}
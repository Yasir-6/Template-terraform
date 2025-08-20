
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.Drazex_ecs_cluster.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.Drazex_ecs_service.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.Drazex_ecs_task_definition.arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "task_security_group_id" {
  description = "ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

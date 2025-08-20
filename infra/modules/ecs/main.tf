
# ECS Cluster
resource "aws_ecs_cluster" "Drazex_ecs_cluster" {
  name = "Drazex-ecs-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "Drazex_ecs_cluster"
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "Drazex_ecs_log_group" {
  name              = "/ecs/${aws_ecs_cluster.Drazex_ecs_cluster.name}"
  retention_in_days = 7

  tags = {
    Name        = "Drazex_ecs_log_group"
    Environment = var.environment
  }
}

# Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "Drazex-ecs-task-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Drazex_ecs_task_execution_role"
    Environment = var.environment
  }
}

# Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "Drazex-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Drazex_ecs_task_role"
    Environment = var.environment
  }
}

# Attach policies to Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Attach policies to Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: Example policy for Task Role to access S3 (customize based on application needs)
resource "aws_iam_role_policy" "ecs_task_role_s3" {
  name = "s3-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::example-bucket/*",
          "arn:aws:s3:::example-bucket"
        ]
      }
    ]
  })
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "Drazex-ecs-tasks-sg-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Drazex_ecs_task_security_group"
    Environment = var.environment
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "Drazex_ecs_task_definition" {
  family                   = "Drazex-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "Drazex-container-${var.environment}"
      image = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [for name in var.env_variable_names : {
        name  = name
        value = "#{aws_ssm_parameter.${name}.value}"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.Drazex_ecs_log_group.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "Drazex_ecs_task_definition"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "Drazex_ecs_service" {
  name                               = "Drazex-service-${var.environment}"
  cluster                           = aws_ecs_cluster.Drazex_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.Drazex_ecs_task_definition.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.use_private_subnets ? var.private_subnet_ids : var.public_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = !var.use_private_subnets
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "Drazex-container-${var.environment}"
    container_port   = var.container_port
  }

  tags = {
    Name        = "Drazex_ecs_service"
    Environment = var.environment
  }
}

# Auto Scaling Target (if enabled)
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_auto_scaling ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.Drazex_ecs_cluster.name}/${aws_ecs_service.Drazex_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.desired_count
  max_capacity       = 10
}

# Auto Scaling Policy (if enabled)
resource "aws_appautoscaling_policy" "ecs_policy" {
  count              = var.enable_auto_scaling ? 1 : 0
  name               = "Drazex-ecs-autoscaling-policy-${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

data "aws_region" "current" {}

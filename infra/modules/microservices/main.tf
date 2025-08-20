# Target Groups for each microservice
resource "aws_lb_target_group" "microservice_target_groups" {
  for_each = var.microservices
  
  name        = "Drazex-${each.key}-tg-${var.environment}"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout            = 5
    interval           = 30
    matcher            = "200"
  }

  tags = {
    Name        = "Drazex_${each.key}_target_group"
    Environment = var.environment
    Service     = each.key
  }
}

# ALB Listener Rules for host-based routing
resource "aws_lb_listener_rule" "microservice_rules" {
  for_each = var.microservices
  
  listener_arn = aws_lb_listener.microservice_listener.arn
  priority     = 100 + index(keys(var.microservices), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservice_target_groups[each.key].arn
  }

  condition {
    host_header {
      values = [each.value.host]
    }
  }
}

# ALB Listener (port 80)
resource "aws_lb_listener" "microservice_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

# Security Group for microservices
resource "aws_security_group" "microservices_sg" {
  name        = "Drazex-microservices-sg-${var.environment}"
  description = "Security group for microservices"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "Drazex_microservices_security_group"
    Environment = var.environment
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "microservice_logs" {
  for_each = var.microservices
  
  name              = "/ecs/Drazex-${each.key}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name        = "Drazex_${each.key}_log_group"
    Environment = var.environment
    Service     = each.key
  }
}

# Task Definitions
resource "aws_ecs_task_definition" "microservice_tasks" {
  for_each = var.microservices
  
  family                   = "Drazex-${each.key}-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name  = "Drazex-${each.key}-container-${var.environment}"
      image = each.value.image
      
      portMappings = [
        {
          containerPort = each.value.port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        for key, value in each.value.env_variables : {
          name  = key
          value = value
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.microservice_logs[each.key].name
          "awslogs-region"        = "us-east-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      essential = true
    }
  ])

  tags = {
    Name        = "Drazex_${each.key}_task_definition"
    Environment = var.environment
    Service     = each.key
  }
}

# ECS Services
resource "aws_ecs_service" "microservice_services" {
  for_each = var.microservices
  
  name                               = "Drazex-${each.key}-service-${var.environment}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.microservice_tasks[each.key].arn
  desired_count                     = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                       = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.microservices_sg.id]
    subnets         = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.microservice_target_groups[each.key].arn
    container_name   = "Drazex-${each.key}-container-${var.environment}"
    container_port   = each.value.port
  }

  depends_on = [aws_lb_listener_rule.microservice_rules]

  tags = {
    Name        = "Drazex_${each.key}_service"
    Environment = var.environment
    Service     = each.key
  }
}

# IAM Roles (shared across microservices)
resource "aws_iam_role" "task_execution_role" {
  name = "Drazex-microservices-execution-role-${var.environment}"

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
    Name        = "Drazex_microservices_execution_role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  name = "Drazex-microservices-task-role-${var.environment}"

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
    Name        = "Drazex_microservices_task_role"
    Environment = var.environment
  }
}
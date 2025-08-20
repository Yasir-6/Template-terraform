
# Target Group
resource "aws_lb_target_group" "Drazex_target_group" {
  name        = "Drazex-target-group-${var.environment}"
  port        = var.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.target_group_health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout            = 5
    interval           = 30
    matcher            = var.target_group_health_check_codes
  }

  tags = {
    Name        = "Drazex_target_group"
    Environment = var.environment
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "Drazex_load_balancer_security_group" {
  name        = "Drazex-lb-sg-${var.environment}"
  description = "Security group for web scraping load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic to ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "Drazex_load_balancer_security_group"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "Drazex_application_lb" {
  name               = "Drazex-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Drazex_load_balancer_security_group.id]
  subnets           = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "Drazex_application_lb"
    Environment = var.environment
  }
}

# Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Drazex_application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Drazex_target_group.arn
  }
}

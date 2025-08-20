terraform {
  backend "s3" {
    bucket         = "Drazex-terraform-statefiles"
    key            = "dev/microservices/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

# Remote state references
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "Drazex-terraform-statefiles"
    key    = "dev/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "Drazex-terraform-statefiles"
    key    = "dev/alb/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = "Drazex-terraform-statefiles"
    key    = "dev/ecs/terraform.tfstate"
    region = "us-east-2"
  }
}

module "microservices" {
  source = "../../../modules/microservices"

  environment = "dev"
  
  # VPC Configuration
  vpc_id             = data.terraform_remote_state.vpc.outputs.Drazex_vpc_id
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.Drazex_private_subnet_one,
    data.terraform_remote_state.vpc.outputs.Drazex_private_subnet_two
  ]
  
  # ALB Configuration
  load_balancer_arn = data.terraform_remote_state.alb.outputs.load_balancer_arn
  alb_security_group_id = data.terraform_remote_state.alb.outputs.load_balancer_security_group_id
  
  # ECS Configuration
  ecs_cluster_id = data.terraform_remote_state.ecs.outputs.cluster_id
  
  # New Microservices Configuration (3 additional services)
  microservices = {
    chat = {
      image = var.chat_image
      port  = 3001
      host  = "chat.drazex.com"
      cpu   = 256
      memory = 512
    }
    payment = {
      image = var.payment_image
      port  = 3002
      host  = "payment.drazex.com"
      cpu   = 256
      memory = 512
    }
    admin = {
      image = var.admin_image
      port  = 3003
      host  = "admin.drazex.com"
      cpu   = 256
      memory = 512
    }
  }
}

# Outputs
output "microservices_target_groups" {
  value = module.microservices.target_group_arns
}

output "microservices_services" {
  value = module.microservices.service_names
}

output "microservices_task_definitions" {
  value = module.microservices.task_definition_arns
}
terraform {
  backend "s3" {
    bucket         = "Drazex-terraform-statefiles"
    key            = "dev/ecs/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# Add remote state references
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

provider "aws" {
  region = "us-east-2"
}

module "ecs" {
  source = "../../../modules/ecs"

  environment            = "dev"
  container_image        = var.container_image
  container_port         = var.container_port
  env_variable_names     = var.env_variable_names
  cpu                    = var.cpu
  memory                 = var.memory
  desired_count          = var.desired_count
  use_private_subnets    = var.use_private_subnets
  enable_auto_scaling    = var.enable_auto_scaling
  env_file_arn       = var.env_file_arn
  vpc_id                 = data.terraform_remote_state.vpc.outputs.Drazex_vpc_id
  private_subnet_ids     = [
    data.terraform_remote_state.vpc.outputs.Drazex_private_subnet_one,
    data.terraform_remote_state.vpc.outputs.Drazex_private_subnet_two
  ]
  public_subnet_ids      = [
    data.terraform_remote_state.vpc.outputs.Drazex_public_subnet_one,
    data.terraform_remote_state.vpc.outputs.Drazex_public_subnet_two
  ]
  alb_security_group_id  = data.terraform_remote_state.alb.outputs.Drazex_load_balancer_security_group_id
  alb_target_group_arn   = data.terraform_remote_state.alb.outputs.Drazex_target_group_arn
}

# Outputs
output "Drazex_ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "Drazex_ecs_service_name" {
  value = module.ecs.service_name
}

output "Drazex_ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}

output "Drazex_ecs_task_execution_role_arn" {
  value = module.ecs.task_execution_role_arn
}

output "Drazex_ecs_task_role_arn" {
  value = module.ecs.task_role_arn
}

output "Drazex_ecs_task_security_group_id" {
  value = module.ecs.task_security_group_id
}

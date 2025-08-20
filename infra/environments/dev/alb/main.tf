terraform {
  backend "s3" {
    bucket         = "Drazex-terraform-statefiles"
    key            = "dev/alb/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# Add remote state reference for VPC
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "Drazex-terraform-statefiles"
    key    = "dev/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "alb" {
  source = "../../../modules/alb"

  vpc_id                         = data.terraform_remote_state.vpc.outputs.Drazex_vpc_id
  public_subnet_ids             = [
    data.terraform_remote_state.vpc.outputs.Drazex_public_subnet_one,
    data.terraform_remote_state.vpc.outputs.Drazex_public_subnet_two
  ]
  target_group_port             = var.target_group_port
  target_group_health_check_path = var.target_group_health_check_path
  target_group_health_check_codes = var.target_group_health_check_codes
  environment                    = "dev"
}

output "Drazex_load_balancer_arn" {
  value = module.alb.load_balancer_arn
}

output "Drazex_target_group_arn" {
  value = module.alb.target_group_arn
}

output "Drazex_load_balancer_security_group_id" {
  value = module.alb.load_balancer_security_group_id
}

output "Drazex_load_balancer_dns_name" {
  value = module.alb.load_balancer_dns_name
}
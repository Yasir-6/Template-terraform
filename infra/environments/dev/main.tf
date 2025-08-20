provider "aws" {
  region = "us-east-2"  # Change this to your desired region
}

# Data source to get VPC outputs
data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

module "alb" {
  source = "../../modules/alb"

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

# Output the ARNs and IDs
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

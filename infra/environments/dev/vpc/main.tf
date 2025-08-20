terraform {
  backend "s3" {
    bucket         = "Drazex-terraform-statefiles"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../../../modules/vpc"

  vpc_cidr = "10.2.0.0/16"
  
  public_subnet_cidrs = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24"
  ]
  
  private_subnet_cidrs = [
    "10.2.100.0/24",
    "10.2.101.0/24",
    "10.2.102.0/24"
  ]
  
  availability_zones = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]
}

output "Drazex_vpc_id" {
  value = module.vpc.vpc_id
}

output "Drazex_public_subnet_one" {
  value = module.vpc.public_subnet_ids[0]
}

output "Drazex_public_subnet_two" {
  value = module.vpc.public_subnet_ids[1]
}

output "Drazex_public_subnet_three" {
  value = module.vpc.public_subnet_ids[2]
}

output "Drazex_private_subnet_one" {
  value = module.vpc.private_subnet_ids[0]
}

output "Drazex_private_subnet_two" {
  value = module.vpc.private_subnet_ids[1]
}

output "Drazex_private_subnet_three" {
  value = module.vpc.private_subnet_ids[2]
}


# VPC Module
resource "aws_vpc" "Drazex_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Drazex_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "Drazex_internet_gateway" {
  vpc_id = aws_vpc.Drazex_vpc.id

  tags = {
    Name = "Drazex_internet_gateway"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "Drazex_nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name = "Drazex_nat_gateway_eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "Drazex_nat_gateway" {
  allocation_id = aws_eip.Drazex_nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "Drazex_nat_gateway"
  }

  depends_on = [aws_internet_gateway.Drazex_internet_gateway]
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.Drazex_vpc.id
  cidr_block             = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Drazex_public_subnet_${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.Drazex_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Drazex_private_subnet_${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "Drazex_public_route_table" {
  vpc_id = aws_vpc.Drazex_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Drazex_internet_gateway.id
  }

  tags = {
    Name = "Drazex_public_route_table"
  }
}

# Private Route Table
resource "aws_route_table" "Drazex_private_route_table" {
  vpc_id = aws_vpc.Drazex_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Drazex_nat_gateway.id
  }

  tags = {
    Name = "Drazex_private_route_table"
  }
}

# Public Subnet Route Table Associations
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.Drazex_public_route_table.id
}

# Private Subnet Route Table Associations
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.Drazex_private_route_table.id
}

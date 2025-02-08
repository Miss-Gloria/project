resource "aws_vpc" "gloria_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Gloria VPC"
  }
}

# Create Two Public Subnets Using `count`
resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.gloria_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "Gloria Public Subnet ${count.index + 1}"
  }
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.gloria_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Gloria Private Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gloria_igw" {
  vpc_id = aws_vpc.gloria_vpc.id
}

# Store IGW ID in SSM Parameter Store
resource "aws_ssm_parameter" "igw_id" {
  name  = "/terraform/gloria_igw_id"
  type  = "String"
  value = aws_internet_gateway.gloria_igw.id
}

# Store Public Subnet IDs in SSM Parameter Store
resource "aws_ssm_parameter" "public_subnet_1_id" {
  name  = "/terraform/public_subnet_id_1"
  type  = "String"
  value = aws_subnet.public_subnet[0].id
}

resource "aws_ssm_parameter" "public_subnet_2_id" {
  name  = "/terraform/public_subnet_id_2"
  type  = "String"
  value = aws_subnet.public_subnet[1].id
}

# Store Private Subnet ID in SSM Parameter Store
resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "/terraform/private_subnet_id"
  type  = "String"
  value = aws_subnet.private_subnet.id
}

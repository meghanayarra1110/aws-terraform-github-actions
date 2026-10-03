terraform {
  backend "s3" {
    bucket       = "meghanayarra-terraform-state-024532670145"
    key          = "terraform.tfstate"
    region       = "ap-northeast-3"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-3"
}

# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-devops-vpc"
  }
}

# -------------------------
# Public Subnet
# -------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "terraform-devops-igw"
  }
}

# -------------------------
# Public Route Table
# -------------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "terraform-public-route-table"
  }
}

# -------------------------
# Route Table Association
# -------------------------
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "devops_sg" {
  name        = "terraform-devops-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.devops_vpc.id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-devops-sg"
  }
}

# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "devops_server" {
  ami                    = "ami-0086ee55a149bd32e"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # Install Docker and run Nginx automatically
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
    docker run -d --name terraform-nginx -p 80:80 nginx:alpine
  EOF

  tags = {
    Name = "terraform-devops-server"
  }
}
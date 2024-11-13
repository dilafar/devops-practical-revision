terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "backup-state"
    key = "jenkins/terraform.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env_prefix}-vpc"
  }

}

resource "aws_subnet" "dev-subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name = "${var.env_prefix}-subnet"
  }

}

resource "aws_internet_gateway" "dev-gateway" {
  vpc_id = aws_vpc.dev-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "dev-route" {
  default_route_table_id = aws_vpc.dev-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-main-route_table"
  }
}


resource "aws_security_group" "dev-sg" {
  name        = "dev-security-group"
  description = "Allow ssh traffic from my ip"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip, var.jenkins_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }

}


data "aws_ami" "dev-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  tags = {
    Name = "${var.env_prefix}-ami"
  }

}


resource "aws_instance" "dev-instance" {
  ami                         = data.aws_ami.dev-ami.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = aws_subnet.dev-subnet.id
  vpc_security_group_ids      = [aws_security_group.dev-sg.id]
  key_name                    = "server-key"
  associate_public_ip_address = true


  user_data = file("script.sh")

  tags = {
    Name = "${var.env_prefix}-instance"
  }

}

output "ec2_public_ip" {
  value = aws_instance.dev-instance.public_ip
}

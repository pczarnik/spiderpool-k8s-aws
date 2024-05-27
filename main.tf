terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

variable "public_key" {
  description = "Path to public SSH key"
  type        = string
  default     = "id_ed25519.pub"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "ec2"
  public_key = file(var.public_key)
}

resource "aws_vpc" "this" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.azs[0]

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat_gw_eip" {
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  subnet_id         = aws_subnet.public.id
  allocation_id     = aws_eip.nat_gw_eip.id
  connectivity_type = "public"
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = var.azs[1]

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private, count.index).id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "bastion" {
  ami                         = local.bastion.ami
  instance_type               = local.bastion.instance_type
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.this.id]

  tags = {
    Name = "bastion"
  }
}

resource "aws_network_interface" "this" {
  for_each        = local.interfaces
  subnet_id       = each.value.subnet_id
  security_groups = [aws_security_group.this.id]
}

resource "aws_instance" "instances" {
  for_each      = local.instances
  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.this.key_name

  dynamic "network_interface" {
    for_each = { for idx, id in each.value.interfaces : idx => id }
    content {
      network_interface_id = network_interface.value
      device_index         = network_interface.key
    }
  }
  tags = {
    Name = each.key
  }
}

output "ami_name" {
  description = "AMI name"
  value       = data.aws_ami.amazon_linux.name
}

output "bastion_dns" {
  description = "Bastion public DNS"
  value       = aws_instance.bastion.public_dns
}




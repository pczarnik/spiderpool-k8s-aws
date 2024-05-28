variable "public_key" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

resource "aws_key_pair" "local" {
  key_name   = "local"
  public_key = file(var.public_key)
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.azs[0]

  tags = {
    Name = "Public Subnet"
  }
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

resource "aws_instance" "bastion" {
  ami                         = local.bastion.ami
  instance_type               = local.bastion.instance_type
  key_name                    = aws_key_pair.local.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main.id]

  tags = {
    Name = "bastion"
  }
}

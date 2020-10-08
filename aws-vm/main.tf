provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_availability_zones" "aws_azs" {
  state = "available"
}

resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}


# CREATE OR USE EXISTING VPC
data "aws_vpc" "vpc" {
  count = var.aws_preexisting_infra ? 1 : 0
  id    = var.aws_vpc_id
}

resource "aws_vpc" "vpc" {
  count                = var.aws_preexisting_infra ? 0 : 1
  cidr_block           = var.aws_vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "dte-2.0-vpc-${random_string.random.result}"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = var.aws_preexisting_infra ? 0 : (var.aws_public ? 1 : 0)
  vpc_id = aws_vpc.vpc[0].id
  tags = {
    Name = "dte-2.0-igw-${random_string.random.result}"
  }

}

resource "aws_route_table" "default" {
  count  = var.aws_preexisting_infra ? 0 : (var.aws_public ? 1 : 0)
  vpc_id = aws_vpc.vpc[0].id
  tags = {
    Name = "dte-2.0-rt-${random_string.random.result}"
  }
}

resource "aws_main_route_table_association" "main_vpc_routes" {
  count  = var.aws_preexisting_infra ? 0 : (var.aws_public ? 1 : 0)
  vpc_id         = aws_vpc.vpc[0].id
  route_table_id = aws_route_table.default[0].id
}

resource "aws_route" "igw_route" {
  count  = var.aws_preexisting_infra ? 0 : (var.aws_public ? 1 : 0)
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.default[0].id
  gateway_id             = aws_internet_gateway.igw[0].id
}

# CREATE OR USE EXISTING SUBNET
data "aws_subnet" "subnet" {
  count  = var.aws_preexisting_infra ? 1 : 0
  vpc_id = data.aws_vpc.vpc[0].id
  id     = var.aws_subnet_id
}

resource "aws_subnet" "subnet" {
  count             = var.aws_preexisting_infra ? 0 : 1
  vpc_id            = aws_vpc.vpc[0].id
  cidr_block        = var.aws_subnet_cidr_block
  availability_zone = data.aws_availability_zones.aws_azs.names[0]
  tags = {
    Name = "dte-2.0-subnet-${random_string.random.result}"
  }
}

# CREATE OR USE EXISTING SECURITY GROUP
data "aws_security_groups" "sg" {
  count = var.aws_preexisting_infra ? 1 : 0
  filter {
    name   = "group-id"
    values = [var.aws_securitygroup_id]
  }
}

resource "aws_security_group" "sg" {
  count  = var.aws_preexisting_infra ? 0 : 1
  vpc_id = var.aws_preexisting_infra ? data.aws_vpc.vpc[0].id : aws_vpc.vpc[0].id
  tags = {
    Name = "dte-2.0-sg-${random_string.random.result}"
  }
}

resource "aws_security_group_rule" "inbound_ssh" {
  count             = var.aws_preexisting_infra ? 0 : 1
  type              = "ingress"
  security_group_id = aws_security_group.sg[0].id

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "outbound_all" {
  count             = var.aws_preexisting_infra ? 0 : 1
  type              = "egress"
  security_group_id = aws_security_group.sg[0].id

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

# CREATE SSH KEY
resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sshkey" {
  key_name   = "dte-2.0-key-${random_string.random.result}"
  public_key = tls_private_key.sshkey.public_key_openssh
}

# CREATE VMS
resource "aws_instance" "vm" {
  count                       = var.aws_vm_count
  ami                         = var.aws_ami_id
  instance_type               = var.aws_vm_flavor
  subnet_id                   = var.aws_preexisting_infra ? data.aws_subnet.subnet[0].id : aws_subnet.subnet[0].id
  vpc_security_group_ids      = var.aws_preexisting_infra ? [data.aws_security_groups.sg[0].ids] : [aws_security_group.sg[0].id]
  availability_zone           = data.aws_availability_zones.aws_azs.names[0]
  key_name                    = aws_key_pair.sshkey.key_name
  associate_public_ip_address = true
  tags = {
    Name = "dte-2.0-vm-${random_string.random.result}"
  }
}

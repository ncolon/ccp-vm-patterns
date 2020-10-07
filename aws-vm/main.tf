provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_vpc" "vpc" {
  count = var.aws_preexisting_infra ? 1 : 0
  id    = var.aws_vpc_id
}

data "aws_subnet" "subnet" {
  count  = var.aws_preexisting_infra ? 1 : 0
  vpc_id = data.aws_vpc.vpc[0].id
  id     = var.aws_subnet_id
}

data "aws_security_groups" "sg" {
  count = var.aws_preexisting_infra ? 1 : 0
  filter {
    name   = "group-id"
    values = [var.aws_securitygroup_id]
  }
}

data "aws_ami" "ami" {
  owners      = ["amazon", "self"]
  most_recent = true

  filter {
    name   = "image-id"
    values = [var.aws_ami_id]
  }
}

data "aws_availability_zones" "aws_azs" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  count      = var.aws_preexisting_infra ? 0 : 1
  cidr_block = var.aws_vpc_cidr_block
}

resource "aws_subnet" "subnet" {
  count             = var.aws_preexisting_infra ? 0 : 1
  vpc_id            = aws_vpc.vpc[0].id
  cidr_block        = var.aws_subnet_cidr_block
  availability_zone = data.aws_availability_zones.aws_azs.names[0]
}

resource "aws_security_group" "sg" {
  count  = var.aws_preexisting_infra ? 0 : 1
  name   = "dte2.0-sg"
  vpc_id = var.aws_preexisting_infra ? data.aws_vpc.vpc[0].id : aws_vpc.vpc[0].id

  ingress {
    description = "dte2.0-sg ingress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}


resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sshkey" {
  key_name   = "dte-2.0-${random_string.random.result}"
  public_key = tls_private_key.sshkey.public_key_openssh
}

resource "aws_instance" "vm" {
  count                  = var.aws_vm_count
  ami                    = data.aws_ami.ami.id
  instance_type          = var.aws_vm_flavor
  subnet_id              = var.aws_preexisting_infra ? data.aws_subnet.subnet[0].id : aws_subnet.subnet[0].id
  vpc_security_group_ids = concat(aws_security_group.sg.*.id, list(data.aws_security_groups.sg[0].ids[0]))
  availability_zone      = data.aws_availability_zones.aws_azs.names[0]
  key_name               = aws_key_pair.sshkey.key_name
}

########################################
# PROVIDER VARIABLES
########################################
variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}
########################################
# END PROVIDER VARIABLES
########################################

########################################
# VM INSTANCE VARIABLES
########################################
variable "aws_vm_count" {
  type    = number
  default = 1
}

variable "aws_ami_id" {
  type = string
}

variable "aws_vm_flavor" {
  type    = string
  default = "t3.micro"
}
########################################
# END VM INSTANCE VARIABLES
########################################

########################################
# INFRASTRUCTURE VARIABLES
########################################
variable "aws_vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "aws_preexisting_infra" {
  type    = bool
  default = false
}

variable "aws_public" {
  type    = bool
  default = true
}

variable "aws_securitygroup_id" {
  type    = string
  default = ""
}

variable "aws_subnet_id" {
  type    = string
  default = ""
}

variable "aws_vpc_id" {
  type    = string
  default = ""
}

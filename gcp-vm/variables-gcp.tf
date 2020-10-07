########################################
# PROVIDER VARIABLES
########################################
variable "gcp_credentials" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_project" {
  type = string
}
########################################
# END PROVIDER VARIABLES
########################################

variable "preexisting_infra" {
  type    = bool
  default = false
}

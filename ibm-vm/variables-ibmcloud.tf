########################################
# END PROVIDER VARIABLES
########################################
variable "softlayer_username" {
  type = string
}

variable "softlayer_api_key" {
  type = string
}

variable "ibmcloud_api_key" {
  type = string
}
########################################
# END PROVIDER VARIABLES
########################################

variable "preexisting_infra" {
  type    = bool
  default = false
}

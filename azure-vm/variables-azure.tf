########################################
# PROVIDER VARIABLES
########################################
variable "azure_subscription_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_environment" {
  type    = string
  default = "public"
}
########################################
# END PROVIDER VARIABLES
########################################

variable "preexisting_infra" {
  type    = bool
  default = false
}

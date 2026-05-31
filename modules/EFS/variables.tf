variable "account_no" {
  type = string
}

variable "username" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "datalayer_sg_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "kms_alias_name" {
  type    = string
  default = "alias/kms"
}

variable "efs_name" {
  type    = string
  default = "ACS-efs"
}

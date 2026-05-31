variable "name" {
  type    = string
  default = "ACS"
}

variable "region" {
  type = string
}

variable "account_no" {
  type = string
}

variable "keypair" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

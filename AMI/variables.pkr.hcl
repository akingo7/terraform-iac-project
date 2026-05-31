variable "region" {
  type    = string
  default = "eu-central-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
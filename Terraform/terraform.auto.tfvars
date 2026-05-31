region                              = "eu-central-1"
preferred_number_of_public_subnets  = 2
preferred_number_of_private_subnets = 2
tags = {
  Environment     = "development"
  Owner-Email     = "infradev@steghub.com"
  Managed-By      = "Terraform"
  Billing-Account = "1234567890"
}

ami_map = {
  eu-central-1 = "ami-0de6934e87badb694"
}

keypair = "devops"

# Ensure to change this to your account number
account_no = "312973238800"
username   = "gabriel.a"


master_username = "steghub"

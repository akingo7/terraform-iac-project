source "amazon-ebs" "terraform-wordpress-prj-19" {
  ami_name      = "terraform-wordpress-prj-19-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }

  ssh_username = "ec2-user"

  tag {
    key   = "Name"
    value = "terraform-wordpress-prj-19"
  }
}

build {
  sources = ["source.amazon-ebs.terraform-wordpress-prj-19"]

  provisioner "shell" {
    script = "../Terraform/wordpress.sh"
  }
}
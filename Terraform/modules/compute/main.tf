locals {
  bucket_name = lower(join("-", [var.name, "bucket", var.region, var.account_no]))
}

resource "aws_key_pair" "infrakey" {
  key_name   = var.keypair
  public_key = file(var.public_key_path)
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "aws assume role" })
}

resource "aws_iam_policy" "policy" {
  name        = "ec2_instance_policy"
  description = "A test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:Describe*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, { Name = "aws assume policy" })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "ip" {
  name = "aws_instance_profile_test"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(var.tags, { Name = local.bucket_name })
}

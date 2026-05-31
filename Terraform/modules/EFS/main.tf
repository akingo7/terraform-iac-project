resource "aws_kms_key" "acs_kms" {
  description = "KMS key "
  policy      = <<EOF
  {
  "Version": "2012-10-17",
  "Id": "kms-key-policy",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${var.account_no}:user/${var.username}" },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "alias" {
  name          = var.kms_alias_name
  target_key_id = aws_kms_key.acs_kms.key_id
}

resource "aws_efs_file_system" "acs_efs" {
  encrypted  = true
  kms_key_id = aws_kms_key.acs_kms.arn

  tags = merge(var.tags, { Name = var.efs_name })
}

resource "aws_efs_mount_target" "subnet_1" {
  file_system_id  = aws_efs_file_system.acs_efs.id
  subnet_id       = var.private_data_subnet_ids[0]
  security_groups = [var.datalayer_sg_id]
}

resource "aws_efs_mount_target" "subnet_2" {
  file_system_id  = aws_efs_file_system.acs_efs.id
  subnet_id       = var.private_data_subnet_ids[1]
  security_groups = [var.datalayer_sg_id]
}

resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.acs_efs.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/wordpress"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = 0755
    }
  }
}

resource "aws_efs_access_point" "tooling" {
  file_system_id = aws_efs_file_system.acs_efs.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/tooling"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = 0755
    }
  }
}

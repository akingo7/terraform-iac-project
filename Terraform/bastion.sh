#!/bin/bash
set -euo pipefail

##############################
# BASTION HOST — UserData
# AMI: Amazon Linux 2023
# Purpose: SSH jump box for managing private-subnet resources
##############################

# ── System update ────────────────────────────────────────
sudo yum update -y

# ── Install essential administration tools ───────────────
sudo yum install -y \
  git \
  vim \
  wget \
  unzip \
  net-tools \
  telnet \
  htop \
  mariadb105   # MariaDB client to reach RDS from bastion

if ! command -v curl &>/dev/null; then
  sudo yum install -y curl --allowerasing
fi

# ── Install AWS CLI v2 (if not already present) ─────────
if ! command -v aws &>/dev/null; then
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -qo /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

# ── Install Amazon EFS utilities (for ad-hoc EFS mounts) ─
sudo yum install -y amazon-efs-utils

# ── Install nmap / ncat for connectivity checks ─────────
sudo yum install -y nmap-ncat

# ── Harden SSH ───────────────────────────────────────────
# Disable root login and password auth (keys only)
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/'             /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# ── Enable and start chronyd (NTP) ──────────────────────
sudo systemctl enable --now chronyd

echo "===== Bastion host provisioning complete ====="

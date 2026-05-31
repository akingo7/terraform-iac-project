#!/bin/bash
set -euo pipefail

##############################
# NGINX — Reverse Proxy UserData
# AMI: Amazon Linux 2023
# Purpose: Receive HTTP from External ALB (which terminates HTTPS),
#          proxy traffic to the Internal ALB over HTTP port 80
##############################

# ── Placeholders (replace with Terraform variables / SSM) ─
INTERNAL_ALB_DNS="internal-int-lb-1352626086.eu-central-1.elb.amazonaws.com"

# ── System update ────────────────────────────────────────
sudo yum update -y

# ── Install NGINX and supporting packages ────────────────
sudo yum install -y nginx

# ── Install AWS CLI v2 ──────────────────────────────────
if ! command -v aws &>/dev/null; then
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -qo /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

# ── Install Amazon EFS utilities ────────────────────────
sudo yum install -y amazon-efs-utils

if [[ "${PACKER_BUILD:-0}" == "1" ]]; then
    echo "PACKER_BUILD detected; skipping runtime NGINX config that depends on live ALB DNS"
    sudo systemctl enable nginx
    exit 0
fi

# ── Write the main NGINX config ─────────────────────────
sudo tee /etc/nginx/nginx.conf > /dev/null << 'NGINX_CONF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid       /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';

    access_log /var/log/nginx/access.log main;

    sendfile        on;
    tcp_nopush      on;
    keepalive_timeout 65;

    # ── Upstream: Internal ALB (HTTP) ────────────────────
    upstream internal_alb {
        server INTERNAL_ALB_DNS_PLACEHOLDER:80;
    }

    # ── HTTP reverse proxy ──────────────────────────────
    # External ALB terminates HTTPS; NGINX receives HTTP
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass             http://internal_alb;
            proxy_set_header       Host $host;
            proxy_set_header       X-Real-IP $remote_addr;
            proxy_set_header       X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header       X-Forwarded-Proto $scheme;
        }

        # Health-check endpoint for the External ALB
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
NGINX_CONF

# ── Inject the real Internal ALB DNS into the config ─────
sudo sed -i "s/INTERNAL_ALB_DNS_PLACEHOLDER/${INTERNAL_ALB_DNS}/" /etc/nginx/nginx.conf

# ── Validate and start NGINX ────────────────────────────
sudo nginx -t
sudo systemctl enable --now nginx

echo "===== NGINX reverse-proxy provisioning complete ====="

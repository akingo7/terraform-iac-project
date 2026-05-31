#!/bin/bash
set -euo pipefail

##############################
# TOOLING APPLICATION — Web Server UserData
# AMI: Amazon Linux 2023  (RHEL-family)
# Purpose: Apache + PHP 8.3 + StegTechHub Tooling App,
#          shared storage on EFS, backed by RDS MySQL
# Repo:    https://github.com/StegTechHub/tooling
##############################

# ── Placeholders (replace with Terraform variables / SSM) ─
EFS_ID="fs-00c2c2e54a6461843"
RDS_ENDPOINT="web-database.cp4u2qc2gkiv.eu-central-1.rds.amazonaws.com"
DB_NAME="tooling_db"
DB_USER="admin"
DB_PASS="zYWinPjgDxNkkAJ68IhB"
TOOLING_DOMAIN="tooling.demo.steghub.com"

EFS_MOUNT="/var/www/html"

# ── System update ────────────────────────────────────────
sudo yum update -y

# ── Install Apache (httpd) ───────────────────────────────
sudo yum install -y httpd git

# ── Start Apache ─────────────────────────────────────────
sudo systemctl enable httpd
sudo systemctl start httpd

# ── Install PHP and required extensions ────────────────
sudo dnf install -y \
  php \
  php-cli \
  php-common \
  php-fpm \
  php-mysqlnd \
  php-xml \
  php-mbstring \
  php-curl \
  php-zip \
  php-gd \
  php-intl \
  php-soap \
  php-opcache

# ── Install EFS utilities & MariaDB client ──────────────
sudo yum install -y amazon-efs-utils mariadb105

# ── Install AWS CLI v2 ──────────────────────────────────
if ! command -v aws &>/dev/null; then
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -qo /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

# ── Mount EFS ────────────────────────────────────────────
sudo mkdir -p "${EFS_MOUNT}"
sudo mount -t efs -o tls "${EFS_ID}:/tooling" "${EFS_MOUNT}"

# Persist mount across reboots
echo "${EFS_ID}:/tooling ${EFS_MOUNT} efs _netdev,tls 0 0" | sudo tee -a /etc/fstab

# ── Clone the Tooling application (only if not on EFS yet)
if [ ! -f "${EFS_MOUNT}/index.php" ]; then
  git clone https://github.com/StegTechHub/tooling.git /tmp/tooling
  sudo cp -a /tmp/tooling/html/. "${EFS_MOUNT}/"
  rm -rf /tmp/tooling
fi

# ── Configure the Tooling app database connection ────────
# The app uses functions.php (or db_conn.php) with a $db variable.
# We update the connection parameters in the codebase.
sudo tee "${EFS_MOUNT}/db_conn.php" > /dev/null << DBCONN
<?php
\$servername = "${RDS_ENDPOINT}";
\$username   = "${DB_USER}";
\$password   = "${DB_PASS}";
\$dbname     = "${DB_NAME}";

\$db = mysqli_connect(\$servername, \$username, \$password, \$dbname);

if (!\$db) {
    die("Connection failed: " . mysqli_connect_error());
}
?>
DBCONN

# Also update DB credentials in functions.php if present
if [ -f "${EFS_MOUNT}/functions.php" ]; then
  sudo sed -i \
    -e "s/mysqli_connect([^)]*)/mysqli_connect('${RDS_ENDPOINT}', '${DB_USER}', '${DB_PASS}', '${DB_NAME}')/" \
    "${EFS_MOUNT}/functions.php"
fi

# ── Import the tooling database schema ───────────────────
# Download the SQL dump directly from the repo
curl -sL https://raw.githubusercontent.com/StegTechHub/tooling/main/tooling-db.sql -o /tmp/tooling-db.sql

# Create the database and import (idempotent — IF NOT EXISTS)
mysql -h "${RDS_ENDPOINT}" -u "${DB_USER}" -p"${DB_PASS}" << SQLEOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
USE \`${DB_NAME}\`;
SQLEOF

mysql -h "${RDS_ENDPOINT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < /tmp/tooling-db.sql || true
rm -f /tmp/tooling-db.sql

# ── Set ownership and permissions ────────────────────────
sudo chown -R apache:apache "${EFS_MOUNT}"
sudo find "${EFS_MOUNT}" -type d -exec chmod 2775 {} +
sudo find "${EFS_MOUNT}" -type f -exec chmod 0664 {} +

# ── Configure Apache VirtualHost ─────────────────────────
sudo tee /etc/httpd/conf.d/tooling.conf > /dev/null << 'APACHECONF'
<VirtualHost *:80>
    ServerName  TOOLING_DOMAIN_PLACEHOLDER
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog  /var/log/httpd/tooling-error.log
    CustomLog /var/log/httpd/tooling-access.log combined
</VirtualHost>
APACHECONF

sudo sed -i "s/TOOLING_DOMAIN_PLACEHOLDER/${TOOLING_DOMAIN}/" /etc/httpd/conf.d/tooling.conf

sudo systemctl restart httpd
echo "===== Tooling application provisioning complete ====="

#!/bin/bash
set -euo pipefail

##############################
# WORDPRESS — Web Server UserData
# AMI: Amazon Linux 2023  (RHEL-family)
# Purpose: Apache + PHP + WordPress mounted on EFS,
#          backed by RDS MySQL
##############################

# ── Placeholders (replace with Terraform variables / SSM) ─
EFS_ID="fs-00c2c2e54a6461843"
RDS_ENDPOINT="web-database.cp4u2qc2gkiv.eu-central-1.rds.amazonaws.com"
DB_NAME="mysql"
DB_USER="admin"
DB_PASS="zYWinPjgDxNkkAJ68IhB"
WP_DOMAIN="demo.steghub.com"

EFS_MOUNT="/var/www/html"

# ── System update ────────────────────────────────────────
sudo yum update -y

# ── Install Apache (httpd) ───────────────────────────────
sudo yum install -y httpd

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

if [[ "${PACKER_BUILD:-0}" == "1" ]]; then
  echo "PACKER_BUILD detected; skipping runtime WordPress EFS/RDS configuration"
  sudo systemctl enable httpd
  exit 0
fi

# ── Install AWS CLI v2 ──────────────────────────────────
if ! command -v aws &>/dev/null; then
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -qo /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

# ── Mount EFS ────────────────────────────────────────────
sudo mkdir -p "${EFS_MOUNT}"
sudo mount -t efs -o tls "${EFS_ID}":/ "${EFS_MOUNT}"

# Persist mount across reboots
echo "${EFS_ID}:/ ${EFS_MOUNT} efs _netdev,tls 0 0" | sudo tee -a /etc/fstab

# ── Download & install WordPress (only if not already on EFS)
if [ ! -f "${EFS_MOUNT}/wp-config-sample.php" ]; then
  curl -sL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
  tar -xzf /tmp/wordpress.tar.gz -C /tmp
  sudo cp -a /tmp/wordpress/. "${EFS_MOUNT}/"
  rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
fi

# ── Generate WordPress salts and write wp-config.php ─────
WP_SALTS=$(curl -sL https://api.wordpress.org/secret-key/1.1/salt/)

sudo tee "${EFS_MOUNT}/wp-config.php" > /dev/null << WPCONFIG
<?php
/** Database settings */
define('DB_NAME',     '${DB_NAME}');
define('DB_USER',     '${DB_USER}');
define('DB_PASSWORD', '${DB_PASS}');
define('DB_HOST',     '${RDS_ENDPOINT}');
define('DB_CHARSET',  'utf8mb4');
define('DB_COLLATE',  '');

/** Site URLs (force HTTPS) */
define('WP_HOME', 'https://${WP_DOMAIN}');
define('WP_SITEURL', 'https://${WP_DOMAIN}');

/** Authentication unique keys and salts */
${WP_SALTS}

/** Table prefix */
\$table_prefix = 'wp_';

/** Reverse-proxy / ALB headers */
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
  \$_SERVER['HTTPS'] = 'on';
}

/** Debugging — disable in production */
define('WP_DEBUG', false);

/** Absolute path to the WordPress directory */
if ( ! defined('ABSPATH') ) {
  define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files */
require_once ABSPATH . 'wp-settings.php';
WPCONFIG

# ── Set ownership and permissions ────────────────────────
sudo chown -R apache:apache "${EFS_MOUNT}"
sudo find "${EFS_MOUNT}" -type d -exec chmod 2775 {} +
sudo find "${EFS_MOUNT}" -type f -exec chmod 0664 {} +

# ── Configure Apache VirtualHost ─────────────────────────
sudo tee /etc/httpd/conf.d/wordpress.conf > /dev/null << 'APACHECONF'
<VirtualHost *:80>
    ServerName  WP_DOMAIN_PLACEHOLDER
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog  /var/log/httpd/wordpress-error.log
    CustomLog /var/log/httpd/wordpress-access.log combined
</VirtualHost>
APACHECONF

sudo sed -i "s/WP_DOMAIN_PLACEHOLDER/${WP_DOMAIN}/" /etc/httpd/conf.d/wordpress.conf

# ── Enable mod_rewrite for WordPress pretty permalinks ───
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

sudo systemctl restart httpd

echo "===== WordPress web-server provisioning complete ====="

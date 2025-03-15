#!/bin/bash

# Exit on any error
set -e

# Check if script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Prompt user for PHP version
echo "Which PHP version would you like to install (e.g., 8.3, 8.2)? Default is 8.3."
read -p "Enter PHP version: " php_version
# Set default to 8.3 if no input is provided
php_version=${php_version:-8.3}

# Validate input (basic check for format like X.Y)
if ! [[ "$php_version" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid PHP version format. Please use a format like '8.3' or '8.2'."
    exit 1
fi

# Update package list
echo "Updating package list..."
apt-get update -y

# Install prerequisites
echo "Installing prerequisites..."
apt-get install -y curl apt-transport-https lsb-release gnupg

# Add Microsoft repository for ODBC Driver
echo "Adding Microsoft repository..."
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Update package list again after adding repo
apt-get update -y

# Install Microsoft ODBC Driver 18
echo "Installing Microsoft ODBC Driver 18..."
ACCEPT_EULA=Y apt-get install -y msodbcsql18
# Optional: Install mssql-tools18 for sqlcmd
ACCEPT_EULA=Y apt-get install -y mssql-tools18
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

# Install unixODBC development headers
apt-get install -y unixodbc-dev

# Add PHP repository (ondrej/php)
echo "Adding PHP repository..."
add-apt-repository -y ppa:ondrej/php
apt-get update -y

# Install PHP and necessary extensions with user-specified version
echo "Installing PHP $php_version..."
apt-get install -y php${php_version} php${php_version}-dev php${php_version}-xml

# Install SQLSRV and PDO_SQLSRV drivers via PECL
echo "Installing SQLSRV and PDO_SQLSRV drivers..."
pecl install sqlsrv
pecl install pdo_sqlsrv

# Enable the extensions in PHP
echo "Configuring PHP extensions..."
echo "extension=sqlsrv.so" > /etc/php/${php_version}/mods-available/sqlsrv.ini
echo "extension=pdo_sqlsrv.so" > /etc/php/${php_version}/mods-available/pdo_sqlsrv.ini
phpenmod -v ${php_version} sqlsrv pdo_sqlsrv

# Restart web server (assuming Apache or PHP-FPM is used)
if systemctl is-active --quiet apache2; then
    echo "Restarting Apache..."
    systemctl restart apache2
elif systemctl is-active --quiet php${php_version}-fpm; then
    echo "Restarting PHP-FPM..."
    systemctl restart php${php_version}-fpm
else
    echo "No web server detected (Apache or PHP-FPM). Please restart your web server manually."
fi

# Verify installation
echo "Verifying PHP extensions..."
php -v  # Show PHP version
php -m | grep -E 'sqlsrv|pdo_sqlsrv' && echo "SQLSRV and PDO_SQLSRV are installed successfully!" || echo "Installation failed. Check logs above."

echo "Installation complete! Test your setup with a PHP script connecting to your SQL Server."

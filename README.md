# PHP & SQL Server Driver Installation Script

This Bash script automates the installation of PHP with SQLSRV and PDO_SQLSRV drivers on an Ubuntu server. It ensures all necessary dependencies are installed and configured properly.

## Features
- Installs PHP (user-selectable version, default 8.3)
- Installs Microsoft ODBC Driver 18
- Installs SQLSRV and PDO_SQLSRV PHP extensions
- Configures PHP extensions automatically
- Restarts Apache or PHP-FPM if detected

## Prerequisites
- A fresh Ubuntu server (20.04 or later)
- Root or sudo access

## Installation & Usage
### Step 1: Download the Script
```bash
git clone https://github.com/PreciousGariya/php-sqlsrv-ubuntu-setup.git
```

### Step 2: Run the Script
```bash
sudo chmod +x install_php_sqlsrv.sh
sudo ./install_php_sqlsrv.sh 
or 
sudo bash install_php_sqlsrv.sh
```

### Step 3: Follow the Prompts
- Enter the desired PHP version (e.g., 8.3, 8.2). If left blank, it defaults to 8.3.

### Step 4: Verify Installation
Run the following command to confirm installation:
```bash
php -m | grep -E 'sqlsrv|pdo_sqlsrv'
```
If the output includes `sqlsrv` and `pdo_sqlsrv`, the installation was successful.

## Troubleshooting
- If PHP extensions are not loaded, try restarting the web server:
  ```bash
  sudo systemctl restart apache2
  sudo systemctl restart php8.3-fpm  # Replace with your PHP version
  ```
- Check installed PHP version:
  ```bash
  php -v
  ```
- Check if SQLSRV extensions are available:
  ```bash
  php -m | grep sqlsrv
  ```

## License
This script is open-source and licensed under the MIT License.

## Author
[Precious Gariya](https://github.com/PreciousGariya) | [☕ Buy Me a Coffee](https://buymeacoffee.com/preciousgariya)


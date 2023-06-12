#!/bin/bash

# Update all installed packages to thier latest versions
sudo yum update -y 

# Install the unzip package, which we will use it to extract the web files from the zip folder
sudo yum install unzip -y

# Install wget package, which we will use it to download files from the internet 
sudo yum install -y wget

# Install Apache
sudo yum install -y httpd

# Install PHP and various extensions
sudo amazon-linux-extras enable php7.4 && \
  sudo yum clean metadata && \
  sudo yum install -y \
    php \
    php-common \
    php-pear \
    php-cgi \
    php-curl \
    php-mbstring \
    php-gd \
    php-mysqlnd \
    php-gettext \
    php-json \
    php-xml \
    php-fpm \
    php-intl \
    php-zip

# Download the MySQL repository package
wget https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm

# Import the GPG key for the MySQL repository
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# Install the MySQL repository package
sudo yum localinstall mysql80-community-release-el7-3.noarch.rpm -y

# Install the MySQL community server package
sudo yum install mysql-community-server -y

# Change directory to the html directory

cd /var/www/html

# Install Git
sudo yum install -y git

# set up aws configs
echo "installing jq"
sudo yum install -y jq 
echo "downloading aws configs script and setting up"
# aws s3 cp s3://s3-terraform-for-dynamic-web/install_aws_cli.sh . --profile devops
# sudo chmod +x install_aws_cli.sh
# ./install_aws_cli.sh


# Set  environment variables from secret manager
PERSONAL_ACCESS_TOKEN=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .PERSONAL_ACCESS_TOKEN`
GITHUB_USERNAME=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .GITHUB_USERNAME`
REPOSITORY_NAME=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .REPOSITORY_NAME`
WEB_FILE_ZIP="rentzone.zip"
WEB_FILE_UNZIP="rentzone"
DOMAIN_NAME="www.fredbitenyo.link"
RDS_ENDPOINT=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .RDS_ENDPOINT`
RDS_DB_NAME=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .RDS_DB_NAME`
RDS_MASTER_USERNAME=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .username`
RDS_DB_PASSWORD=`aws secretsmanager get-secret-value --secret-id rentzone-app-dev-secrets --profile devops | \
                        jq --raw-output '.SecretString' | jq -r .password`

# Clone the GitHub repository
git clone https://$PERSONAL_ACCESS_TOKEN@github.com/$GITHUB_USERNAME/$REPOSITORY_NAME.git

# Unzip the zip folder containing the web files
unzip $REPOSITORY_NAME/$WEB_FILE_ZIP -d $REPOSITORY_NAME/

# Copy the web files into the HTML directory
sudo cp -av $REPOSITORY_NAME/$WEB_FILE_UNZIP/. /var/www/html

# Remove the repository we cloned
sudo rm -rf $REPOSITORY_NAME

# Enable the mod_rewrite setting in the httpd.conf file
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Give full access to the /var/www/html directory
sudo chmod -R 777 /var/www/html

# Give full access to the storage directory
sudo chmod -R 777 storage/

# Use the sed command to search the .env file for a line that starts with APP_ENV= and replace everything after the = character
sudo sed -i '/^APP_ENV=/ s/=.*$/=production/' .env

# Use the sed command to search the .env file for a line that starts with APP_URL= and replace everything after the = character
sudo sed -i "/^APP_URL=/ s/=.*$/=https:\/\/$DOMAIN_NAME\//" .env

# Use the sed command to search the .env file for a line that starts with DB_HOST= and replace everything after the = character
sudo sed -i "/^DB_HOST=/ s/=.*$/=$RDS_ENDPOINT/" .env

# Use the sed command to search the .env file for a line that starts with DB_DATABASE= and replace everything after the = character
sudo sed -i "/^DB_DATABASE=/ s/=.*$/=$RDS_DB_NAME/" .env 

# Use the sed command to search the .env file for a line that starts with DB_USERNAME= and replace everything after the = character
sudo sed -i "/^DB_USERNAME=/ s/=.*$/=$RDS_MASTER_USERNAME/" .env

# Use the sed command to search the .env file for a line that starts with DB_PASSWORD= and replace everything after the = character
sudo sed -i "/^DB_PASSWORD=/ s/=.*$/=$RDS_DB_PASSWORD/" .env

# start apache service
sudo systemctl start httpd

# NextCloud Installation on Ubuntu 24.04 LTS

## References
- [Official Ubuntu Guide](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)
- [Apache Configuration](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#apache-configuration-label)

## Install Dependencies

    sudo apt update && sudo apt upgrade
    sudo apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql \
    php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip

### Configure DB
    sudo mysql_secure_installation

		In order to log into MariaDB to secure it, we'll need the current
		password for the root user. If you've just installed MariaDB, and
		haven't set the root password yet, you should just press enter here.

		Enter current password for root (enter for none): # PRESS ENTER
		OK, successfully used password, moving on...


		Switch to unix_socket authentication [Y/n] Y
		Enabled successfully!
		Reloading privilege tables..
		... Success!

		Change the root password? [Y/n] Y
		New password: 
		Re-enter new password: 
		Password updated successfully!
		Reloading privilege tables..
		... Success!

		Remove anonymous users? [Y/n] Y
		... Success!

		Disallow root login remotely? [Y/n] Y
		... Success!

		Remove test database and access to it? [Y/n] Y
		- Dropping test database...
		... Success!
		- Removing privileges on test database...
		... Success!

		Reload privilege tables now? [Y/n] Y
		... Success!

Create the user
    sudo mysql

Then a MariaDB [root]> prompt will appear. Now enter the following lines, replacing username and password with appropriate values, and confirm them with the Enter key:

    CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
    CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    GRANT ALL PRIVILEGES ON nextcloud.* TO 'username'@'localhost';
    FLUSH PRIVILEGES;

You can quit the prompt by entering:

    quit;

## Install Nextcloud
    wget https://download.nextcloud.com/server/releases/latest.zip
    
    unzip latest.zip

Copy the Nextcloud directory to its final destination. When you are running the Apache HTTP server you may safely install Nextcloud in your Apache document root:

    sudo cp -r nextcloud /var/www

Finally, change the ownership of your Nextcloud directories to your HTTP user:

    sudo chown -R www-data:www-data /var/www/nextcloud

## Configure Apache Web server

Create apache config

    sudo nano /etc/apache2/sites-available/nextcloud.conf

Add

    <VirtualHost *:80>
    DocumentRoot /var/www/nextcloud/
    ServerName  your.server.com

    <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
        Dav off
        </IfModule>
    </Directory>
    </VirtualHost>

Run the following command to enable the configuration:

    sudo a2ensite nextcloud.conf

### Additional Apache configurations
For Nextcloud to work correctly, we need the module mod_rewrite. Enable it by running:
Additional recommended modules are mod_headers, mod_env, mod_dir and mod_mime:

    a2enmod rewrite
    a2enmod headers
    a2enmod env
    a2enmod dir
    a2enmod mime

Now restart Apache:

    service apache2 restart

### Enable SSL
    sudo apt install certbot python3-certbot-apache
    sudo certbot --apache
Check autorenew is active:
    sudo systemctl status certbot.timer


## Configure PHP
Configure memory 512mb

    sudo nano /etc/php/8.3/apache2/php.ini
    replace memory_limit = 128M to memory_limit = 512M


## Configure Nextcloud

Use the occ command to complete your installation. This takes the place of running the graphical Installation Wizard:

    cd /var/www/nextcloud/
    sudo -u www-data php occ  maintenance:install \
    --database='mysql' --database-name='nextcloud' \
    --database-user='root' --database-pass='password' \
    --admin-user='admin' --admin-pass='password'

Edit config.php:

    sudo nano /var/www/nextcloud/config/config.php 
Add

    'skeletondirectory' => '',
    'trusted_domains' => domain_name,
    'simpleSignUpLink.shown' => false,

### Configure users

    sudo -u www-data php occ group:add guest
    sudo -u www-data php occ user:add --display-name="Guest" --group="guest" Guest

### Install Apps
#### Install groupfolders
    sudo -u www-data php occ app:install groupfolders
    sudo -u www-data php occ groupfolders:create /

Configure permissions

    sudo -u www-data php occ groupfolders:group 1 admin write share delete
    sudo -u www-data php occ groupfolders:group 1 guest

### Disable app
    sudo -u www-data php occ app:disable federation sharebymail nextcloud_announcements webhook_listeners
    sudo -u www-data php occ app:disable photos dashboard activity firstrunwizard app_api weather_status







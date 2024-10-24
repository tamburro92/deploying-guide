
https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html


## Install dependecy
    sudo apt update && sudo apt upgrade
    sudo apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql \
    php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip

## Configure DB
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
Now download the archive of the latest Nextcloud version:

Go to the Nextcloud Install Page.
https://nextcloud.com/install/

Go to Download Server > Community Projects and download either the tar.bz2 or .zip archive.

    wget https://download.nextcloud.com/server/releases/latest.zip
Now you can extract the archive contents. Run the appropriate unpacking command for your archive type:

    tar -xjvf nextcloud-x.y.z.tar.bz2
    unzip nextcloud-x.y.z.zip

This unpacks to a single nextcloud directory.

Copy the Nextcloud directory to its final destination. When you are running the Apache HTTP server you may safely install Nextcloud in your Apache document root:

    sudo cp -r nextcloud /var/www

Finally, change the ownership of your Nextcloud directories to your HTTP user:

    sudo chown -R www-data:www-data /var/www/nextcloud


## Apache Web server configuration
Configuring Apache requires the creation of a single configuration file. On Debian, Ubuntu, and their derivatives, this file will be /etc/apache2/sites-available/nextcloud.conf

You can choose to install Nextcloud in a directory on an existing webserver, for example https://www.example.com/nextcloud/, or in a virtual host if you want Nextcloud to be accessible from its own subdomain such as https://cloud.example.com/.

To use the directory-based installation, put the following in your nextcloud.conf replacing the Directory and Alias filepaths with the filepaths appropriate for your system:

    Alias /nextcloud "/var/www/nextcloud/"

    <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>

To use the virtual host installation, put the following in your nextcloud.conf replacing ServerName, as well as the DocumentRoot and Directory filepaths with values appropriate for your system:

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
On Debian, Ubuntu, and their derivatives, you should run the following command to enable the configuration:

    a2ensite nextcloud.conf

### Additional Apache configurations
For Nextcloud to work correctly, we need the module mod_rewrite. Enable it by running:

    a2enmod rewrite

Additional recommended modules are mod_headers, mod_env, mod_dir and mod_mime:

    a2enmod headers
    a2enmod env
    a2enmod dir
    a2enmod mime

If you’re running mod_fcgi instead of the standard mod_php also enable:

    a2enmod setenvif

You must disable any server-configured authentication for Nextcloud, as it uses Basic authentication internally for DAV services. If you have turned on authentication on a parent folder (via e.g. an AuthType Basic directive), you can turn off the authentication specifically for the Nextcloud entry. Following the above example configuration file, add the following line in the <Directory> section:

    Satisfy Any

When using SSL, take special note of the ServerName. You should specify one in the server configuration, as well as in the CommonName field of the certificate. If you want your Nextcloud to be reachable via the internet, then set both of these to the domain you want to reach your Nextcloud server.

Now restart Apache:

    service apache2 restart

If you’re running Nextcloud in a subdirectory and want to use CalDAV or CardDAV clients make sure you have configured the correct Service discovery URLs.


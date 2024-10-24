# Frappe-ERPNext-Version-15--in-Ubuntu-22.04-LTS
A complete Guide to Install Frappe/ERPNext version 15  in Ubuntu 22.04 LTS

## Install Bench
### Update APT
	sudo apt update -y
	sudo apt upgrade -y

### Install git 
	sudo apt-get install git

### Install python-dev virtualenv  
	sudo apt-get install python3-dev
	sudo apt-get install python3-setuptools python3-pip
	sudo apt-get install virtualenv
	sudo apt install python3-venv

### Install MariaDB
	sudo apt-get install software-properties-common
	sudo apt install mariadb-server
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

### MySQL database development files

	sudo apt-get install libmysqlclient-dev

### Edit the mariadb configuration ( unicode character encoding )

	sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

add this to the 50-server.cnf file

    [server]
    user = mysql
    pid-file = /run/mysqld/mysqld.pid
    socket = /run/mysqld/mysqld.sock
    basedir = /usr
    datadir = /var/lib/mysql
    tmpdir = /tmp
    lc-messages-dir = /usr/share/mysql
    bind-address = 127.0.0.1
    query_cache_size = 16M
    log_error = /var/log/mysql/error.log

    [mysqld]
    innodb-file-format=barracuda
    innodb-file-per-table=1
    innodb-large-prefix=1
    character-set-client-handshake = FALSE
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci      

    [mysql]
    default-character-set = utf8mb4

Now press (Ctrl-X) to exit

    sudo service mysql restart

### Install Redis
	sudo apt-get install redis-server

### Install Node.js 18.X package

	sudo apt install curl 
	curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
	source ~/.profile
	nvm install 18

	sudo apt-get install npm
	sudo npm install -g yarn


### Install wkhtmltopdf (with patched qt) (NOT FROM APT)
	sudo apt-get install xvfb libfontconfig

https://discuss.frappe.io/t/print-pdf-header-footer-not-showing-letterhead/85030/6

	sudo apt-get install xfonts-75dpi
	wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_arm64.deb
	sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_arm64.deb
	sudo cp /usr/local/bin/wkhtmlto* /usr/bin/
	sudo chmod a+x /usr/bin/wk*

### Install Frappe

	sudo pip3 install frappe-bench --break-system-packages

## Configure new Site

### Initilize the frappe bench & install frappe latest version 
	bench init frappe-15 --frappe-branch version-15

	bench new-site [site]
	bench setup add-domain --site [site-name]  [domain-name]
	bench use [site]

### Download Apps from repo
	bench get-app --branch  version-15 erpnext
	bench get-app --branch  version-15 healthcare
	bench get-app tamburro92/frappe-health_upgrade

### Install apps

	bench --site [site] install-app erpnext healthcare health_upgrade 

## Setup production

### Setup Multitenant and SSL
	bench config dns_multitenant on

Use lets-encrypt and add a voice to crontab

	sudo bench setup lets-encrypt [site-name] --custom-domain [domain-name]
	#or wildcard
	sudo bench setup wildcard-ssl erpnext.xyz --email test@example.com

	#sudo bench renew-lets-encrypt
	#sudo apt install certbot python3-certbot-nginx

### Setup production
    
	sudo pip3 install ansible --break-system-packages
	sudo bench setup production [user]
	bench --site all enable-scheduler
	bench restart

	#bench disable-production

### if js and css file is not loading on login window run the following command
	sudo usermod -aG [user] www-data

or

	chmod -R o+rx /home/[frappe-user]



## Extra
### Create swapfile
	sudo fallocate -l 2G /swapfile
	ls -lh /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile

make permanent

	sudo nano /etc/fstab
Add lines:

	/swapfile swap swap defaults 0 0
Now press (Ctrl-X) to exit

	swapon --show
	sudo sysctl -w vm.swappiness=1

### Configure S3 Backup
	sudo apt-get install awscli
 	sudo chmod +x s3_backup.sh
	crontab -e
Add lines:

	0 0 * * * /home/ubuntu/s3_backup.sh # Run S3 Backup every day at midnight

### BACKUP / RESTORE
	bench --site all backup --with-files --compress --backup-path backups
	bench --site {site} backup --with-files
	bench --site {site} restore {path/to/database/file}
		--with-public-files {path/to/public/archive}
		--with-private-files {path/to/private/archive}

		--force

### UPDATE IN PRODUCTION
	bench update --reset

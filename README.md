52.25.145.161

##Quick Start
login as root and run following command:

	bash setup_server.sh
This shell script will help to

* Add a user named `grader`
* Give `grader` sudo permission
* Update all currently installed packages
* Change the SSH port from 22 to 2200
* Disable remote login of root user
* Configure the Universal Firewall to only allow incoming connections for SSH (port 2200), HTTP (port 80), and NTP (port 123)
* Configure the local timezone to UTC

##Configuration Detail
###Database Setup (PostgreSQL)
After installing PostgreSQL, it will generate a database called `postgres` and a database user called `postgres`. Also it will add a Linux user `postgres`. We use postgres to create a database called `catalog`.

	su postgres -c 'createdb catalog'
	
Then we change user from `root` to `postgres` in order to set up the user for the `catalog` database we just created.
	
	su postgres
	psql

Under psql we connect to database `catalog` and create a user named catalog with password `udacity` then quit psql.

	\c catalog
	create user catalog PASSWORD 'udacity';
Back to `root` then switch to user `catalog` set up the app using
	
	su catalog
###Clone app from Github

Navigate to `/var/www` and clone the app from github.
	
	git clone https://github.com/nickyfoto/restaurtant.git catalog
	
rename and database setup
	
	mv project.py item_catalog.py
	python database_setup.py
	python data_insert.py

To run your application you need a `item_catalog.wsgi` file. This file contains the code mod_wsgi is executing on startup to get the application object. The object called application in that file is then used as application. 

	import sys
	sys.path.insert(0, '/var/www/catalog')
	from item_catalog import app as application

Run following comand to make sure there is no permission error:

	sudo chown -R catalog:catalog /var/www/catalog/
	sudo chmod -R 755 /var/www

###Configuring Apache

The last thing you have to do is to set the Apache VirtualHost file at `/etc/apache2/sites-available/000-default.conf`:

In order to use Google OAuth login, we need to redirect the service IP address to amazon's domain address using `mod_rewrite`.
	
	<VirtualHost *:80>
    ServerName 52.25.145.161
    
	RewriteEngine on
	RewriteCond %{HTTP_HOST} ^52\.25\.145\.161$
	RewriteRule "^/(.*)$" "http://ec2-52-25-145-161.us-west-2.compute.amazonaws.com/$1" [L,R]
	
    WSGIDaemonProcess item_catalog user=catalog group=admin threads=5
    WSGIScriptAlias / /var/www/catalog/item_catalog.wsgi
    Alias /static /var/www/catalog/static
    <Directory /var/www/catalog>
        WSGIProcessGroup item_catalog
        WSGIApplicationGroup %{GLOBAL}
        Order deny,allow
        Allow from all
    </Directory>
	</VirtualHost>
	
Enable mod_rewrite and finnally restart server:
	
	a2enmod rewrite
	reboot
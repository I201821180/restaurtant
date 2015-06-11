#!/bin/bash
# assume current user is root
# create catalog user

userName="catalog"
result=$(grep $userName /etc/passwd)
if [[ -z $result ]]; then
    echo 'Adding user $userName'
    adduser catalog
else
    echo "User $var has been added to the system. Next step."
fi

# check user if existd
userName="grader"
result=$(grep $userName /etc/passwd)
if [[ -z $result ]]; then
    echo 'Adding user $userName'
    adduser grader
    usermod -a -G admin grader
else
    echo "User $var has been added to the system. Next step."
fi
# update and upgrade the installed packages
apt-get dist-upgrade
apt-get update  
apt-get -u upgrade -y

# update sshd_config
portNumber="Port 2200"
path='/etc/ssh/sshd_config'
result=$(grep -w "^$portNumber" $path)
if [[ -z $result ]]; then
    echo 'Updating sshd_config'
    sed -i 's/Port 22/Port 2200/' $path
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' $path
    sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' $path
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' $path
    sed -i 's/UsePAM yes/UsePAM no/' $path
else
    echo "$result has been placed. Next step."
fi
service ssh restart
# update ufw policy
# https://help.ubuntu.com/community/UFW
ufw allow ntp
ufw allow http
ufw allow 2200
ufw enable
# configure to UTC time
timedatectl set-timezone Europe/London

# Setup database and migration
# install git
apt-get install git
# install apache2, mod_wsgi and PostgreSQL and dependencies
apt-get install -y libapache2-mod-wsgi apache2 postgresql
apt-get -qqy install postgresql python-psycopg2
apt-get -qqy install python-flask python-sqlalchemy
apt-get -qqy install python-pip
pip install bleach
pip install oauth2client
pip install requests
pip install httplib2
# install following package to prevent Google OAuth Login problem
pip install werkzeug==0.8.3
pip install flask==0.9
pip install Flask-Login==0.1.3

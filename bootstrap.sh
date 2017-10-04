#!/usr/bin/env bash

setenforce 0

rpm -Uvh http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm

# ---------------------------------------
#          PHP Setup 
# ---------------------------------------

yum install httpd httpd mod_ssl -y

chkconfig httpd on




# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ProxyPreserveHost On
#    ProxyPass        "/app" "http://localhost/"
#    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
Redirect / https://localhost:8443
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf/httpd.conf





# setup the virtual host /var/www/html/app

VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/app"
      <Directory "/var/www/html/app">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require local
    </Directory>
    # Other directives here
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf/httpd.conf



# ---------------------------------------
#          PHP Setup
# ---------------------------------------

yum install php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml -y



sed -i '/mod_foo.so/a LoadModule php5_module modules/libphp5.so' /etc/httpd/conf/httpd.conf
sed -i '/NameVirtualHost/a NameVirtualHost *:443' /etc/httpd/conf/httpd.conf

yum install memcached -y
service memcached start


# ---------------------------------------
#         Cronjob Setup :: to check the process is up or not
# ---------------------------------------
VHOST=$(cat <<EOF
#!/bin/bash

exec >> /tmp/cronjob.log 2>&1
set -xv

cat2 () { tee -a /dev/stderr; }

ps -ef | cat2 | grep 11211 | grep memcached
if [ $? -ne 0 ]; then
        service memcached restart
else
        echo "eq 0 - memcache running - do nothing"
fi

exit 0
EOF
)
echo "${VHOST}" > /home/vagrant/exercise-memcached.sh

crontab -l | { cat; echo "*/5 * * * * /home/vagrant/exercise-memcached.sh > /dev/null 2>&1"; } | crontab 



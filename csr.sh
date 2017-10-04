#!/bin/bash

mkdir /etc/httpd/ssl
mkdir /var/www/html/app

subj="/C=IN/ST=MH/L=Mumbai/O=IT/CN=localhost"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/test.key \
 -out /etc/httpd/ssl/test.crt -subj "$(echo -n "$subj" | tr "\n" "/")"


# installing the ssl certificate
VHOST=$(cat <<EOF
<VirtualHost *:443>
ServerName localhost:443
SSLEngine on
SSLCertificateFile /etc/httpd/ssl/test.crt
SSLCertificateKeyFile /etc/httpd/ssl/test.key 
ProxyPreserveHost On
#    ProxyPass        "/app" "http://localhost/"
#    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf.d/ssl.conf


VHOST=$(cat <<EOF
<VirtualHost *:443>
DocumentRoot "/var/www/html/app"
SSLEngine on
SSLCertificateFile /etc/httpd/ssl/test.crt
SSLCertificateKeyFile /etc/httpd/ssl/test.key 
ProxyPreserveHost On
      <Directory "/var/www/html/app">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require local
    </Directory>
    ProxyPass        "/app" "http://localhost/"
    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf.d/ssl.conf

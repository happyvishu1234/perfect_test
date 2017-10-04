#!/bin/bash

# Bash shell script for generating self-signed certs. Run this in a folder, as it
# generates a few files. Large portions of this script were taken from the
# following artcile:
#
# http://usrportage.de/archives/919-Batch-generating-SSL-certificates.html
#
# Additional alterations by: Brad Landers
# Date: 2012-01-27

# Script accepts a single argument, the fqdn for the cert

mkdir /etc/httpd/ssl

cd /etc/httpd/ssl

DOMAIN="test.com"
if [ -z "$DOMAIN" ]; then
  echo "Usage: $(basename $0) <domain>"
  exit 11
fi

fail_if_error() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}

# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)

# Certificate details; replace items in angle brackets with your own info
subj="/C=IN/ST=MH/L=Mumbai/O=IT/CN=localhost"

# Generate the server private key
#openssl genrsa -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048
fail_if_error $?

# Generate the CSR
#openssl req \
#    -new \
#    -batch \
#    -subj "$(echo -n "$subj" | tr "\n" "/")" \
#    -key $DOMAIN.key \
#    -out $DOMAIN.csr \
#    -passin env:PASSPHRASE

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/test.key  -out /etc/httpd/ssl/test.crt -subj "$(echo -n "$subj" | tr "\n" "/")"

fail_if_error $?
cp $DOMAIN.key $DOMAIN.key.org
fail_if_error $?

# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE
fail_if_error $?

# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
fail_if_error $?


# installing the ssl certificate
VHOST=$(cat <<EOF
<VirtualHost *:443>
ServerName localhost:443
SSLEngine on
SSLCertificateFile /etc/httpd/ssl/test.com.crt
SSLCertificateKeyFile /etc/httpd/ssl/test.com.key 
ProxyPreserveHost On
    ProxyPass        "/app" "http://localhost/"
    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf.d/ssl.conf

service httpd restart

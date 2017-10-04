#!/bin/bash


cat /vagrant/src/test.txt > /var/www/html/app/test.php


/etc/init.d/httpd restart
#!/usr/bin/env bash

##-------------------------------------------------------
# UPDATE CONFIG FILES
##-------------------------------------------------------

# set timezone machine to America/Sao_Paulo
cp /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# set UTF-8 environment
echo 'LC_ALL=fi_FI.UTF-8' >> /etc/environment
echo 'LANG=fi_FI.UTF-8' >> /etc/environment
echo 'LC_CTYPE=fi_FI.UTF-8' >> /etc/environment


# enable xdebug
echo 'xdebug.remote_enable=1' >> /etc/php/7.0/mods-available/xdebug.ini
echo 'xdebug.remote_connect_back=1' >> /etc/php/7.0/mods-available/xdebug.ini
echo 'xdebug.show_error_trace=1' >> /etc/php/7.0/mods-available/xdebug.ini
echo 'xdebug.remote_port=9000' >> /etc/php/7.0/mods-available/xdebug.ini
echo 'xdebug.scream=0' >> /etc/php/7.0/mods-available/xdebug.ini
echo 'xdebug.show_local_vars=1' >> /etc/php/7.0/mods-available/xdebug.ini
echo 'xdebug.idekey=PHPSTORM' >> /etc/php/7.0/mods-available/xdebug.ini


# set PHP7 timezone to Europe/Helsinki
sed -i "s/;date.timezone =*/date.timezone = Europe\/Helsinki/" /etc/php/7.0/fpm/php.ini
sed -i "s/;date.timezone =*/date.timezone = Europe\/Helsinki/" /etc/php/7.0/cli/php.ini

# setup php7.0-fpm to not run as daemon (allow my_init to control)
sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini

# create run directories
mkdir -p /var/run/php
chown -R www-data:www-data /var/run/php
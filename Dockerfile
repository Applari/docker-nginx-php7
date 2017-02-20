# https://hub.docker.com/r/ttaranto/docker-nginx-php7/
FROM phusion/baseimage
MAINTAINER Esa Heiskanen <esa@applari.fi>

# ensure UTF-8
RUN locale-gen fi_FI.UTF-8
ENV LANG       fi_FI.UTF-8
ENV LC_ALL     fi_FI.UTF-8

# todo: generate and use these variables in the scripts
ENV ENVIROMENT  	production
ENV MYSQL_ROOTUSER	root      
#ENV MYSQL_ROOTPW	
ENV MYSQL_USER		wp
ENV MYSQL_PASS		kissa
ENV MYSQL_HOST		localhost
ENV WP_DB			applariwp
ENV WP_DB_USER		wpuser
ENV WP_DB_PASSWD	kissa1234
ENV WP_USER			applariadmin
ENV WP_PASSWD 		applaripw
ENV GITHUB_ACCESS_TOKEN	965b94daa978dde4945c8ae29a35559a6f7f3a57

# phusion setup
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh # Disable ssh
CMD ["/sbin/my_init"]

# nginx-php installation
#RUN DEBIAN_FRONTEND="noninteractive" apt-get install software-properties-common
#RUN DEBIAN_FRONTEND="noninteractive" apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
#RUN DEBIAN_FRONTEND="noninteractive" add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.netinch.com/pub/mariadb/repo/10.1/ubuntu xenial main'

RUN DEBIAN_FRONTEND="noninteractive" apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade
RUN DEBIAN_FRONTEND="noninteractive" apt-get update --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install apt-utils curl wget git 
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.0 
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-mbstring php7.0-soap php7.0-xml php7.0-zip php-xdebug php-mysql php-imagick

#### install nginx (full)
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx-full

### MariaDB/MySQL installation (needo37/mariadb)

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -qy mariadb-server

# NOT WORKING! Tweak my.cnf
# RUN sed -i -e 's#\(bind-address.*=\).*#\1 0.0.0.0#g' /etc/mysql/my.cnf
# RUN sed -i -e 's#\(log_error.*=\).*#\1 /db/mysql_safe.log#g' /etc/mysql/my.cnf
# RUN sed -i -e 's/\(user.*=\).*/\1 nobody/g' /etc/mysql/my.cnf

RUN echo "log_error=/db/mysql_safe.log" >> /etc/mysql/conf.d/mysql.cnf

# InnoDB engine to use 1 file per table, vs everything in ibdata.
# RUN echo '[mysqld]' > /etc/mysql/conf.d/innodb_file_per_table.cnf
# RUN echo 'innodb_file_per_table' >> /etc/mysql/conf.d/innodb_file_per_table.cnf

VOLUME /db

#End MariaDB

### PHP7-FPM

# add configs 
ADD build/php.ini /etc/php/7.0/fpm/
ADD build/php-fpm.conf /etc/php/7.0/fpm/


# install php composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Add WP-CLI
RUN curl -o /usr/local/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar ;\
	mv /usr/local/wp-cli.phar /usr/local/bin/wp ;\
	chmod +x /usr/local/bin/wp
# allow wp-cli run as root by default
RUN echo -e '\nwp() \n {  \n /usr/local/bin/wp "$@" --allow-root --path=/var/www/public/ \n } \n' >> /root/.bashrc 

# add build script (also set timezone to Europe/Helsinki)
RUN mkdir -p /root/setup
ADD build/setup.sh /root/setup/setup.sh
RUN chmod +x /root/setup/setup.sh
RUN (cd /root/setup/; /root/setup/setup.sh)

# copy files from repo
ADD build/nginx.conf /etc/nginx/sites-available/default
ADD build/.bashrc /root/.bashrc

### disable services start

RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

RUN update-rc.d -f apache2 remove
RUN update-rc.d -f nginx remove
RUN update-rc.d -f php7.0-fpm remove

# add startup scripts for nginx
ADD build/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# add startup scripts for php7.0-fpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/phpfpm/run


# add startup scripts for mariadb
RUN mkdir /etc/service/mariadb
ADD build/mariadb.sh /etc/service/mariadb/run
RUN chmod +x /etc/service/mariadb/run
# CHANGE TO DB LOGS RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#    && ln -sf /dev/stderr /var/log/nginx/error.log


# set WWW public folder
RUN mkdir -p /var/www/public
# ADD build/index.php /var/www/public/index.php
#RUN cd /var/www/public && git clone https://$GITHUB_ACCESS_TOKEN:x-oauth-basic@github.com/Applari/docker-test-index.git && mv docker-test-index/* . && rm -rf docker-test-index && ls -la


RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www

# add scripts
RUN echo "Add checkAndInstallWP.sh"
ADD build/checkAndInstallWP.sh /usr/local/bin
RUN chmod +x /usr/local/bin/checkAndInstallWP.sh

# TODO: add adminer script to ease db dev https://github.com/vrana/adminer/releases/download/v4.2.5/adminer-4.2.5-en.php

# TODO: install wordpress if not installed


# set terminal environment
ENV TERM=xterm

# port and settings
EXPOSE 80 3306

# cleanup apt and lists
RUN apt-get clean
RUN apt-get autoclean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

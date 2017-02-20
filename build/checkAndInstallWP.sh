#!/bin/bash

#helper functions
check_env(){
        varname=$1
        eval value=\$$1

        if [ -z $value ]; then
                echo "ERROR: Not Set: $varname = $value"
                return 1
                #exit 1
        else
                echo "OK: Variable set: $varname = $value"
                return 0
        fi
}


mysql_start(){
    /usr/bin/mysqld_safe --datadir=/db > /dev/null 2>&1 &
    RET=1
    while [[ RET -ne 0 ]]; do
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
        sleep 1
    done
}

mysql_stop(){
  /etc/init.d/mysql stop
}

check_wpcli(){
  if hash wp 2>/dev/null; then
        echo "wp-cli is installed"
        return 0
    else
        echo "wp-cli is not installed"
        # todo: install wp-cli if not installed
        return 1
    fi
}

check_wp(){
  # Check if wordpress is installed
  if $(wp core is-installed --allow-root --path=/var/www/public/); then
    echo "core is installed"
    return 0
  else
    echo "core or db tables are not installed properly"
    #wp core install
    return 1
  fi
}

# Check Env variables
#if [[ -z "${WP_DB}" ]]; then
#       echo "WP_DB not set"
#       exit 1;
#else
#       echo "\$WP_DB set to $WP_DB"
#fi

#[ -z "$WP_DB_PASSWD" ]    && echo "WP_DB_PASSWD not set"; exit 1     || echo "\$WP_DB_PASSWD set to $WP_DB_PASSWD"
#[ -z $WP_USER ]         && { echo "WP_USER not set"; exit 1}            || echo "\$WP_USER set to $WP_USER"
#[ -z $WP_PASSWD ]       && { echo "WP_PASSWD not set"; exit 1}          || echo "\$WP_PASSWD set to $WP_PASSWD"
echo "Checking enviroment"

check_env WP_DB
check_env WP_DB_PASSWD
check_env WP_DB_USER
check_env WP_USER
check_env WP_PASSWD

#Check wp-cli todo: if not installed, install 
if ! check_wpcli; then exit 1; fi

#check wp installation todo: if not installed, install
if ! check_wp; then exit 1; fi

echo "OK: WP and WP-CLI are installed"


# if not, install

## start wp
#RUN start_mysql
# RUN /etc/init.d/mysql start;\
#	sleep 3
##
#RUN echo 'CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO "wordpress"@"localhost" IDENTIFIED BY "wordpress"; FLUSH PRIVILEGES;' | mysql -hlocalhost -uamdin -ppass;\
#	cd /var/www/html;\
#	wp --allow-root core download;\
#	wp --allow-root core config --dbhost="localhost" --dbname="wordpress" --dbuser="admin" --dbpass="pass";\
#	wp --allow-root core install --url="localhost" --title="My Docker Wordpress Blog!" --admin_user="admin" --admin_password="admin" --admin_email="me@localhost";\
#	chown -R www-data:www-data ./*;\
#	/etc/init.d/mysql stop


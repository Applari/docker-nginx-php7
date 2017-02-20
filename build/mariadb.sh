#!/bin/bash
start_mysql(){
    /usr/bin/mysqld_safe --datadir=/db > /dev/null 2>&1 &
    RET=1
    while [[ RET -ne 0 ]]; do
        mysql -uroot -e "status" > /dev/null 2>&1
        echo "."
        RET=$?
        sleep 1
    done
}



# If databases do not exist create them
if [ -f /db/mysql/user.MYD ]; then
  echo "Database exists."
else
  echo "Creating wp database and user."
  /usr/bin/mysql_install_db --datadir=/db >/dev/null 2>&1
  start_mysql
  # not needed mysql -uroot -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$MYSQL_HOST';"
  # mysql -uroot -e "PASSWORD FOR '$MYSQL_USER'@'$MYSQL_HOST' = PASSWORD('$MYSQL_PASS');"
  mysql -uroot -e "CREATE DATABASE IF NOT EXISTS $WP_DB;"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON $WP_DB.* TO '$MYSQL_USER'@'$MYSQL_HOST' WITH GRANT OPTION; " #creates user too if not exist
  mysql -uroot -e "FLUSH PRIVILEGES;"


  # changemyqs root passwordadd default change password
  # mysqladmin -u root -p'' password newpass
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ROOTUSER'@'$MYSQL_HOST' WITH GRANT OPTION;FLUSH PRIVILEGES;" 
  #ALTER USER '$MYSQL_ROOTUSER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_ROOTPW';FLUSH PRIVILEGES;"
  #RUN echo -e "[client]\nuser=$MYSQL_ROOTUSER\npassword=$MYSQL_ROOTPW\n" >> ~/.my.cnf #used automatically



  #not he
 #echo "Create wordpress db : applariwp "
 #mysql -uroot -e "CREATE DATABASE applariwp;"
 #echo "created wordpress user applariwp"
#mysql -uroot -e "CREATE USER 'applariwpuser'@'localhost' IDENTIFIED BY 'kissa';"
 # mysql -uroot -e "GRANT ALL PRIVILEGES ON applariwp.* TO 'applariwpuser'@'localhost' WITH GRANT OPTION;"
  #echo "done  USER 'applariwpuser'@'localhost' IDENTIFIED BY 'kissa'; and granted permissions"
  #mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  #mysql -uroot -e "FLUSH PRIVILEGES;"
  mysqladmin -u root shutdown
fi

echo "Starting MariaDB..."
#/usr/bin/mysqld_safe --skip-syslog --datadir='/db'
/usr/bin/mysqld_safe --datadir='/db' --log-error --syslog


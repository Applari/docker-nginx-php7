#!/bin/bash
start_mysql(){
    /usr/bin/mysqld_safe --datadir=/db > /dev/null 2>&1 &
    RET=1
    while [[ RET -ne 0 ]]; do
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
        sleep 1
    done
}

# If databases do not exist create them
if [ -f /db/mysql/user.MYD ]; then
  echo "Database exists."
else
  echo "Creating database and root-user."
  /usr/bin/mysql_install_db --datadir=/db >/dev/null 2>&1
  start_mysql
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  mysql -uroot -e "FLUSH PRIVILEGES;"

  #not here
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
/usr/bin/mysqld_safe --datadir='/db' --log-error


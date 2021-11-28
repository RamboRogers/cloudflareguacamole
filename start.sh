#!/bin/bash

# Start the database
mariadbd &

sleep 3

#this should only run once....
#don't hate the player, hate the game
if [ -f /root/setupComplete ]; then
  echo "Setup Completed Already"
else
  mysql < /root/setup.sql
  sleep 2
  cat /root/guacamole-auth-jdbc-1.3.0/mysql/schema/*.sql | mysql -D guacamole_db
  touch /root/setupComplete
fi
# Start the guacd daemon
guacd

# Start the client
export CATALINA_HOME=/usr/share/tomcat9
export CATALINA_BASE=/var/lib/tomcat9
/usr/share/tomcat9/bin/catalina.sh start


# Start the tunnel
cloudflared tunnel run guacamole
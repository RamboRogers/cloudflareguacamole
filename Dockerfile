FROM debian:latest
LABEL maintainer="matt@matthewrogers.org"

ENV HOME /root
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV GOPATH /root/go
ENV DEBIAN_FRONTEND noninteractive

### Change this to Match your Cloudflare!!!!!! 
ENV CLOUDFLARETEAM yourcloudflareteamname
ENV TZ America/New_York
###

#ADD local insideContainer
ADD setup.sql /root/setup.sql
ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh
RUN mkdir /etc/guacamole
RUN mkdir /etc/guacamole/lib
ADD guacamole.properties /etc/guacamole/guacamole.properties

#Instlal CloudflareD
RUN apt update 
RUN apt install wget -y
RUN wget https://github.com/cloudflare/cloudflared/releases/download/2021.11.0/cloudflared-linux-amd64.deb -O /root/cloudflared.deb
RUN dpkg -i /root/cloudflared.deb
RUN rm /root/cloudflared.deb

#Start The Tunnel and Login
RUN cloudflared tunnel login
#Makes this cert /root/.cloudflared/cert.pem

#Creates the tunnel and adds the DNS
RUN cloudflared tunnel create guacamole

#Setup Guacamole
RUN apt install guacd -y
RUN apt install tomcat9 -y
RUN apt install iproute2 -y
RUN apt install mariadb-server -y
RUN apt install libmariadb-java -y
RUN mkdir /var/run/mysqld
RUN chown -R mysql:root /var/run/mysqld

#Setup the Guacamole Client in Tomcat
RUN wget "https://apache.org/dyn/closer.lua/guacamole/1.3.0/binary/guacamole-1.3.0.war?action=download" -O /var/lib/tomcat9/webapps/guacamole.war
RUN ln -s /etc/guacamole/ /var/lib/tomcat9/.guacamole
RUN mkdir /usr/share/tomcat9/logs
RUN ln -s /usr/share/java/mariadb-java-client.jar /etc/guacamole/lib/
RUN export CATALINA_HOME=/usr/share/tomcat9
RUN export CATALINA_BASE=/var/lib/tomcat9
RUN mkdir /etc/guacamole/extensions

#Get the DB Driver for Guacamole
RUN wget https://apache.org/dyn/closer.lua/guacamole/1.3.0/binary/guacamole-auth-jdbc-1.3.0.tar.gz?action=download -O /root/guacamole-auth-jdbc-1.3.0.tar.gz
RUN tar xvfz /root/guacamole-auth-jdbc-1.3.0.tar.gz -C /root/
RUN cp /root/guacamole-auth-jdbc-1.3.0/mysql/guacamole-auth-jdbc-mysql-1.3.0.jar /etc/guacamole/extensions
ADD config.yml /root/.cloudflared/config.yml

#Lets add the DNS at the End, this seems to cause a problem if we do it within a milisecond as it will attach to an existing tunnel
RUN cloudflared tunnel route dns guacamole guacamole

EXPOSE 8080/tcp

# Run this thing
CMD ["/root/start.sh"]

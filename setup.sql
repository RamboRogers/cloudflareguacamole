CREATE DATABASE guacamole_db; 
CREATE USER 'admin'@'localhost' IDENTIFIED BY '24e36b2a001af051231bed64d6ac049ad968cd1f';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;

create database ambari default character set='utf8';

CREATE USER 'ambari'@'localhost' IDENTIFIED BY 'admin123';

CREATE USER 'ambari'@'192.168.6.152' IDENTIFIED BY 'admin123';

CREATE USER 'ambari'@'%' IDENTIFIED BY 'admin123';

GRANT ALL PRIVILEGES ON ambari.* TO 'ambari'@'localhost' IDENTIFIED BY 'admin123' with grant option;  

GRANT ALL PRIVILEGES ON ambari.* TO 'ambari'@'192.168.6.152' IDENTIFIED BY 'admin123' with grant option;  

GRANT ALL PRIVILEGES ON ambari.* TO 'ambari'@'%' IDENTIFIED BY 'admin123' with grant option;

FLUSH PRIVILEGES;

SELECT * FROM mysql.`user` WHERE `User`='ambari';
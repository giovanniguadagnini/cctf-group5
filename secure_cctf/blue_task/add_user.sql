DROP USER 'root'@'localhost';
CREATE USER 'root'@'localhost' IDENTIFIED BY 'rootmysql';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE USER 'php_user'@'localhost' IDENTIFIED BY '|AttackersWontFindOut@';
GRANT SELECT ON ctf2.users TO 'php_user'@'localhost';
GRANT SELECT ON ctf2.transfers TO 'php_user'@'localhost';
GRANT INSERT ON ctf2.users TO 'php_user'@'localhost';
GRANT INSERT ON ctf2.transfers TO 'php_user'@'localhost';
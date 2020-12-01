DROP USER 'root'@'localhost';
CREATE USER 'root'@'localhost' IDENTIFIED BY '@ThisIsASecurePassword|';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE USER 'php_user'@'localhost' IDENTIFIED BY '|AttackersWontFindOut@';
GRANT SELECT ON ctf2.users TO 'php_user'@'localhost';
GRANT SELECT ON ctf2.transfers TO 'php_user'@'localhost';
GRANT INSERT ON ctf2.users TO 'php_user'@'localhost';
GRANT INSERT ON ctf2.transfers TO 'php_user'@'localhost';
ALTER TABLE ctf2.users MODIFY COLUMN pass char(64) NOT NULL;
ALTER TABLE ctf2.users ENGINE = InnoDB;
ALTER TABLE ctf2.transfers ENGINE = InnoDB;
ALTER TABLE ctf2.transfers ADD CONSTRAINT users_transfers_fk FOREIGN KEY (user) REFERENCES ctf2.users(user);
UPDATE ctf2.users SET pass = "$2y$10$hjH9n9FD8RtYhH7bNyDRw.tzrJmGR1yXUPWfevaeuZFwd6thfPEw." WHERE user = "jelena" and pass = "abcdef"; -- 2#Fj5DQAeabApy9Z (randomly generated with LastPass)
UPDATE ctf2.users SET pass = "$2y$10$WYWRzt9h3LwJKribmS3uZ.qSOEOiOYfYxVFBg5rBtkWoyxlhJgDnW" WHERE user = "john" and pass = "abcdef"; -- vD85@&3Fj*VbKyu%
UPDATE ctf2.users SET pass = "$2y$10$0jfgFbjr1m2Kf5B2HMGkB.IlR5q3TDODv4JrcMyhBlaAuF1w7TJrK" WHERE user = "kate" and pass = "abcdef"; -- U5j^^dt6G@4QeZhE
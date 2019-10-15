#!/bin/sh
read "Please enter a user (suggested format: user@maildomain.com)" user

hash='doveadm pw -s BLF-CRYPT'
mysql -u root -p somedb -e "mysql> INSERT INTO `mailserver`.`virtual_users`
  (`id`, `domain_id`, `password` , `email`)
VALUES
  ('1', '1', '$hash', '$user');"
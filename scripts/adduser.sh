#!/bin/sh
read -p "Please enter an e-mail adress for your new user: " user

hash=docker exec -it dockermail_dovecot_1 doveadm pw -s BLF-CRYPT
docker exec -it dockermail_database_1 mysql -u root -psecret mailserver -e "INSERT INTO virtual_users (domain_id, password , email) VALUES ('1', '$hash', '$user');"
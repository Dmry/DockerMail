#!/bin/sh

apt install -y fail2ban

hostfiles = "../hostsetup"

containers=(dovecot postfix)

for item in ${array[*]}
do
    cp $hostfiles/fail2ban-$item-action.conf /etc/fail2ban/action.d/
    cp $hostfiles/fail2ban-$item-filter.conf /etc/fail2ban/filter.d/
done

cp $hostfiles/jail.local /etc/fail2ban/

echo "ssh port?\n"

read ssh

sed -i 's/port = ssh/port = $ssh/g' /etc/fail2ban/jail.local
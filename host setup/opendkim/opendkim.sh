#!/bin/bash

read -p "Warning, be sure to only execute this script from the original folder (host setup/opendkim) of the dockermail root folder. The root folder must also contain the postfix files in the similarly named folder. Continue (y/n)?" answer

while true
do
  case $answer in
   [yY]* )  echo "Domain name?"

            read domain

            apt-get install opendkim opendkim-tools
            mkdir -pv /etc/opendkim/
            opendkim-genkey -r -h rsa-sha256 -d $domain -s /etc/opendkim/mail
            mv -v /etc/opendkim/mail.private /etc/opendkim/mail

            echo "Use the output below to make a TXT record at your DNS with the following format (bracketed is optional):"
            echo "mail._domainkey[.subdomain]      300 TXT 'v=DKIM1; h=rsa-sha256; k=rsa; p=KeYreTuRnEdBeLoW"

            cat /etc/opendkim/mail.txt;

            chown -Rv opendkim:opendkim /etc/opendkim
            chmod -R go-rwx /etc/opendkim
            break ;;
   [nN]* )  exit;;

   * )      echo "y or n."; break ;;
  esac
done
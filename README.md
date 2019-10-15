# DockerMail

This is under development and should not be used in production!

Still to be implemented:
* Generate signed certificates with letsencrypt on the host and mount in containers.
* Automated backup of docker volumes
* Watchtower base image updates

## Contents

On the host:  
* Docker-compose is used to configure, build and run all the different docker images, volumes and the network.
* Fail2Ban monitors logs for DDOS and brute force attempts on Postfix, Dovecot and SSH. It can be configured to block any unwanted activity.
* OpenDKIM is a tool to help identify legitimate email and helps to prevent e-mail spoofing. Practically, it helps you get through spam filters. OpenDKIM keys have to be generated on the machine and subsequently set in a DNS record. To prevent having to set a new DNS record on every container build, we do this on the host and mount the key in the container.
  
The different containers:  
<<<<<<< HEAD
*   MySQL is used as the database. User passwords are hashed with BCRYPT before storage.
*   Dovecot is used as the IMAP server and is configured to only accept TLS connections at port 993. Certificates are self-signed.
*   Postmap is used as the SMTP server and is configured to only accept STARTTLS auth connections at port 25. This requires authentication using your imap credentials. Certificates are self-signed.
=======
* MySQL is used as the database. User passwords are hashed with BCRYPT before storage.
* Dovecot is used as the IMAP server and is configured to only accept TLS connections at port 993. Certificates are self-signed.
* Postmap is used as the SMTP server and is configured to only accept STARTTLS auth connections at port 25. This requires authentication using your imap credentials. Certificates are self-signed.
>>>>>>> 7ab2758205479b03ea6b277105565c5af8c13e7f
  * E-mail is sent over TLS when the receiving end supports it. You can make TLS encryption mandatory by setting smtp_tls_security_level=encrypt in the Dockerfile. WARNING: this _will_ lead to email not being delivered. [Nor does postfix recommend this](http://www.postfix.org/postconf.5.html#smtp_tls_security_level).
  * The authentication is done in Base64 encoding and relies on SSL to keep the authentication safe. The only real alternative is (CRAM-)MD5, but that would only allow storage of password hashes using (the very easily crackable) MD5 hash. Given that MD5 is unsafe and the algorithm also provides no source validation, I find it does not provide any real extra security over Base64.
  * OpenDKIM and OpenDMARC help to prevent e-mail spoofing and make sure your e-mail gets through spam filters.
* ClamAV is used to scan e-mail for virusses.
  * Freshclam will automatically update the virus definitions.
  
Some general remarks about the containers:  
* Dovecot and Postfix containers are based on [Alpine Linux](https://www.alpinelinux.org/). MySQL is pulled from the official repository (see [dockerhub page](https://hub.docker.com/r/mysql/mysql-server)).
* Only the Dovecot and Postmap containers expose one port each to the internet. Containers establish connections to each other on docker's isolated network or access sockets through shared volumes.
* Data is persisted using docker volumes see running volumes `docker volume list`. Optional backups up will be automated at a later stage. For now, docker volumes can be backed up by following [this doc](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes).
* Containers update the packages contained within them daily using the apk package manager. The base images (Alpine and MySQL) have to be updated manually be rebuilding the container. I'll soon implement watchtower to automate this.
* Supervisor is used to start processes and log their output.

Running without ClamAV (when memory is scarce):  

## Requirements

Hardware:  
* 1 CPU
* 2 GB RAM

## Preparing the host

NOTE: The (outdated) version of docker-compose in Ubuntu 18.04.3's repository seems to have a breaking bug in it. I've added a manual install in docker.sh.

Scripts to automate host configuration and dependencies can be found in the 'hostsetup' folder. Run the shell scripts in each folder, don't forget to `chmod +x` and run as sudo (be sure to verify that they won't break anythin on your system!). Review the contents section for the purpose of the different scripts.  
  
WARNING: Not running these may lead to a broken install and will compromise security.

## Setting DNS records

We need a bunch of DNS records (next to the normal MX record for mail). Replace maildomain.com with your domain, optionally [mxtoolbox.com](https://mxtoolbox.com/) can generate these for you for more advanced setups:  

* _dmarc.maildomain.com   300 TXT v=DMARC1; p=reject; rua=mailto:postmaster@maildomain.com; ruf=mailto:postmaster@maildomain.com; pct=100
* maildomain.com 300  TXT v=spf1 mx -all  TTL 300
* mail._domainkey 300 TXT 'v=DKIM1; h=rsa-sha256; k=rsa; p=KeYreTuRnEdBeLoW
  
The last record of the list above is generated by opendkim.sh and can be found in `/etc/opendkim/mail.txt`.

## Preparing container files

Replace maildomain.com with your domain in:  
* postfix/Dockerfile
* postfix/opendmarc.conf
* scripts/db-init.sql
  
The MySQL user account 'mailuser' is used to fetch mail, set an appropriate long, random password by replacing 'mailuserpass' in:  
* docker-compose.yml
* dovecot/dovecot-sql.conf.ext
* postfix/mysql-virtual-alias-maps.cf
* postfix/mysql-mailbox-domains.cf
* postfix/mysql-mailbox-maps.cf
* scripts/db-init.sql

Set an appropriate long, random password as the MYSQL_ROOT_PASSWORD in:
* docker-compose.yml

## Getting docker running

`cd` into the dockermail directory. Run `docker-compose up -d` to set up and run the containers.

If you use only one domain, you can use scripts/adduser.sh to generate new users for IMAP and SMTP.

## OpSec

I highly advise you to change the mysql root password you set in the files after running all of this. You can use the following and substitute 'PASSWORD':

```
docker exec -it dockermail_database_1  
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'PASSWORD';
```

This will persist in the database through rebuilds.  

Another piece of advise: remove the mailuser password from the files above after you're done.

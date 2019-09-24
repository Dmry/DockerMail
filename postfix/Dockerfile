FROM ubuntu:latest

RUN apt-get update &&\
    apt-get -y install curl &&\
    apt-get -qq -y install curl &&\
    apt-get install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-mysql dovecot-lmtpd

RUN postconf -e smtpd_tls_cert_file=/etc/ssl/certs/dovecot.pem &&\
    postconf -e smtpd_tls_key_file=/etc/ssl/private/dovecot.pem &&\
    postconf -e smtpd_use_tls=yes &&\
    postconf -e smtpd_tls_auth_only=yes &&\
    postconf -e smtp_tls_security_level = may &&\
    postconf -e smtp_tls_loglevel = 2 &&\
    postconf -e smtpd_tls_received_header = yes &&\
    postconf -e smtpd_sasl_type = dovecot &&\
    postconf -e smtpd_sasl_path = private/auth &&\
    postconf -e smtpd_sasl_auth_enable = yes &&\
    postconf -e smtpd_recipient_restrictions = '\
        permit_sasl_authenticated,\
        permit_mynetworks,\
        reject_unauth_destination' &&\
    postconf -e mydestination = localhost &&\
    postconf -e virtual_transport = lmtp:unix:private/dovecot-lmtp &&\
    postconf -e virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf &&\
    postconf -e virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf &&\
    postconf -e virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf &&\
    postconf -e local_recipient_maps = $virtual_mailbox_maps

ADD mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
ADD mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
ADD mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
FROM alpine:latest

LABEL maintainer="Daniël Emmery : github.com/dmry"

RUN addgroup -g 3001 postfix &&\
    adduser -D -s /sbin/nologin -u 2001 -G postfix postfix &&\
    addgroup -g 3002 opendmarc &&\
    adduser -D -s /sbin/nologin -u 2002 -G opendmarc opendmarc &&\

#for opendmarc
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk add -uU openssl ca-certificates postfix postfix-mysql opendkim opendmarc supervisor && \
    rm -rf /var/cache/apk/* &&\
    echo "0       4       *       *       *       apk update && apk upgrade > /var/log/cron-apk.log" >> /var/spool/cron/crontabs/root

RUN echo "maildomain.com maildomain.com:mail:/etc/opendkim/mail" > /etc/opendkim/KeyTable &&\
    echo "*@maildomain.com maildomain.com"                       > /etc/opendkim/SigningTable &&\
    echo "127.0.0.1"                                             > /etc/opendkim/TrustedHosts

COPY ./opendkim.conf /etc/opendkim/
RUN install -d -o opendkim -g opendkim /var/run/opendkim -m 750

COPY ./opendmarc.conf /etc/opendmarc/opendmarc.conf
COPY ./ignore.hosts /etc/opendmarc/ignore.hosts
RUN install -d -o postfix -g postfix /var/run/opendmarc -m 750

RUN postconf -e smtpd_tls_cert_file=/etc/ssl/certs/postfix.pem &&\
    postconf -e smtpd_tls_key_file=/etc/ssl/private/postfix.pem &&\
    postconf -e smtpd_use_tls=yes &&\
    postconf -e smtpd_tls_auth_only=yes &&\
    postconf -e smtp_tls_security_level=may &&\
    postconf -e smtp_tls_loglevel=2 &&\
    postconf -e smtpd_milters=inet:av:6666,inet:127.0.0.1:6667,unix:/var/run/opendmarc/opendmarc.sock &&\
    postconf -e milter_default_action=accept &&\
    postconf -e smtpd_tls_received_header=yes &&\
    postconf -e smtpd_sasl_type=dovecot &&\
    postconf -e smtpd_sasl_path=private/dovecot/auth &&\
    postconf -e non_smtpd_milters= $smtpd_milters &&\
    postconf -e smtpd_sasl_auth_enable=yes &&\
    postconf -e smtpd_recipient_restrictions='\
        permit_sasl_authenticated,\
        permit_mynetworks,\
        reject_unauth_destination' &&\
    postconf -e mydestination=localhost, maildomain.com &&\
    postconf -e virtual_transport=lmtp:unix:private/dovecot/lmtp &&\
    postconf -e virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf &&\
    postconf -e virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf &&\
    postconf -e virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf &&\
    postconf -e local_recipient_maps=$virtual_mailbox_maps

ADD mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
ADD mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
ADD mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf

RUN chmod 600 /etc/postfix/*.cf

RUN mkdir -p /var/spool/postfix/private/dovecot

RUN postconf maillog_file=/var/log/postfix.log

COPY ./supervisord.d/*.ini /etc/supervisord.d/
COPY supervisord.conf /etc/

RUN chown opendkim:opendkim /etc/opendkim/mail

ENTRYPOINT ["supervisord"]
CMD []
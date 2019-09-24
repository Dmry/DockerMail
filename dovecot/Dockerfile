FROM alpine:latest

RUN addgroup -g 3001 dovecot
RUN adduser -D -s /sbin/nologin -u 2001 -G dovecot dovecot

RUN apk add -uU openssl ca-certificates dovecot && \
    rm -rf /var/cache/apk/*

RUN openssl req -subj "/C=NL/CN=Unknown" -new -x509 -days 1000 -nodes -out "/etc/ssl/certs/dovecot.pem" -keyout "/etc/ssl/private/dovecot.pem"

ADD dovecot.conf /etc/dovecot/dovecot.conf
ADD dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
ADD conf.d/ /etc/dovecot/conf.d/

RUN chown -R mail:dovecot /etc/dovecot &&\
    chmod -R o-rwx /etc/dovecot

ENTRYPOINT "dovecot"
CMD ["dovecot"]

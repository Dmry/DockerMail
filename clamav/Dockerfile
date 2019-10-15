FROM alpine:latest

RUN apk add -uU clamav clamav-milter freshclam supervisor && \
    rm -rf /var/cache/apk/* &&\
    echo "0       4       *       *       *       apk update && apk upgrade > /var/log/cron-apk.log" >> /var/spool/cron/crontabs/root

RUN adduser -D -s /sbin/nologin -u 2001 -G clamav clamav

#RUN sed -i 's/#sieve_extensions = +notify +imapflags/sieve_extensions = +vnd.dovecot.filter/g' /etc/fail2ban/jail.local
#RUN sed -i 's/#sieve_plugins =/sieve_plugins = sieve_extprograms/g' /etc/dovecot/conf.d/90-sieve.conf

COPY ./clamav-milter.conf /etc/clamav/
COPY ./clamd.conf /etc/clamav/

RUN chown -R clamav:clamav /var/run/clamav

COPY ./supervisord.d/*.ini /etc/supervisord.d/
COPY ./supervisord.conf /etc/

CMD supervisord
FROM alpine:latest

RUN apk add -uU clamav clamav-milter freshclam supervisor && \
    rm -rf /var/cache/apk/*

#RUN sed -i 's/#sieve_extensions = +notify +imapflags/sieve_extensions = +vnd.dovecot.filter/g' /etc/fail2ban/jail.local
#RUN sed -i 's/#sieve_plugins =/sieve_plugins = sieve_extprograms/g' /etc/dovecot/conf.d/90-sieve.conf

COPY ./clamav-milter.conf /etc/clamav/
COPY ./clamd.conf /etc/clamav/

RUN mkdir -p /run/clamav/ && chown -R clamav.clamav /var/run/clamav/

COPY ./supervisord.d/*.ini /etc/supervisord.d/
COPY ./supervisord.conf /etc/

CMD supervisord
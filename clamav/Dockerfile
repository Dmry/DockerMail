FROM alpine:latest

RUN apk add -uU clamav freshclam supervisor && \
    rm -rf /var/cache/apk/*

#RUN sed -i 's/#sieve_extensions = +notify +imapflags/sieve_extensions = +vnd.dovecot.filter/g' /etc/fail2ban/jail.local
#RUN sed -i 's/#sieve_plugins =/sieve_plugins = sieve_extprograms/g' /etc/dovecot/conf.d/90-sieve.conf

COPY ./supervisord.d/*.ini /etc/supervisord.d/
COPY ./supervisord.conf /etc/

CMD supervisord
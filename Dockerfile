FROM centos/systemd

ENV TZ GMT+7:00

ENV proxy_password=$PROXY_PASSWD

RUN \
    yum -y update \
    && yum -y install squid \
    && systemctl enable squid \
    && yum -y install httpd-tools \
    && touch /etc/squid/passwd \
    && chown squid: /etc/squid/passwd \
    && grep -B 99999 "^acl CONNECT method CONNECT$" < /etc/squid/squid.conf.default > /etc/squid/squid.conf \
    && echo  " \
\
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd \
auth_param basic children 5 \
auth_param basic realm Squid Basic Authentication \
auth_param basic credentialsttl 2 hours \
acl auth_users proxy_auth REQUIRED \
http_access allow auth_users \
\
" >> /etc/squid/squid.conf \
    && grep -A 99999 "^acl CONNECT method CONNECT$" < /etc/squid/squid.conf.default >> /etc/squid/squid.conf


WORKDIR "/"

CMD ["htpasswd -b /etc/squid/passwd proxyclient $proxy_password"]
CMD ["/usr/sbin/init"]

#ENTRYPOINT ["/bin/nologin"]

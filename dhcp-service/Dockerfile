FROM debian:buster-slim

USER root

RUN apt-get update && apt-get install -y curl \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    nginx
RUN curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/gpg/gpg.0607E2621F1564A6.key' | apt-key add -
RUN curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/setup/config.deb.txt?distro=debian&codename=buster' > /etc/apt/sources.list.d/isc-kea-1-6.list
RUN apt-get update && apt-get install -y isc-kea-* default-mysql-client awscli netcat

WORKDIR /home
RUN chown root:root /home
COPY ./start_service.sh ./start_service.sh
COPY ./dhcp_test.sh ./dhcp_test.sh
RUN  mkdir /var/run/kea

EXPOSE 67/udp
# TODO: delete this?
EXPOSE 68/udp
EXPOSE 80

RUN service nginx start

CMD ["./start_service.sh"]

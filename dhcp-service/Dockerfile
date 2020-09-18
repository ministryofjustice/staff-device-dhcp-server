FROM alpine:3.11

RUN  apk add bash curl nginx && \
    curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-8/cfg/setup/bash.alpine.sh' |  bash && \
    apk upgrade && apk add python3 mysql mysql-client isc-kea-admin isc-kea-perfdhcp isc-kea-dhcp4 && \
    pip3 install awscli && pip3 install --upgrade pip && mkdir -p /run/nginx


WORKDIR /home
RUN chown root:root /home
COPY ./bootstrap.sh ./bootstrap.sh
COPY ./config.json ./test_config.json

EXPOSE 67/udp
EXPOSE 68/udp
EXPOSE 80

CMD ["./bootstrap.sh"]

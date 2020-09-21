FROM alpine:3.11

ENV GLIBC_VER=2.31-r0

RUN apk add bash curl nginx mysql mysql-client && \
    curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-8/cfg/setup/bash.alpine.sh' |  bash && \
    apk upgrade && apk add isc-kea-admin isc-kea-perfdhcp isc-kea-dhcp4 && \
    mkdir -p /run/nginx && \
    curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
    apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk && \
    curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    aws/install && \
    rm -rf awscliv2.zip aws /usr/local/aws-cli/v2/*/dist/aws_completer /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index /usr/local/aws-cli/v2/*/dist/awscli/examples && \
    rm glibc-${GLIBC_VER}.apk && \
    rm glibc-bin-${GLIBC_VER}.apk && \
    rm -rf /var/cache/apk/* && \
    cp -r usr/share/kea/kea/scripts/ usr/share/kea/

COPY ./bootstrap.sh ./bootstrap.sh
COPY ./config.json ./test_config.json
COPY ./dhcp_test.sh ./dhcp_test.sh

EXPOSE 67/udp
EXPOSE 68/udp
EXPOSE 80

CMD ["./bootstrap.sh"]

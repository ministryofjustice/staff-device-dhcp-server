ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/dhcp:ruby-2-7-2-alpine3-11

ENV GLIBC_VER=2.31-r0
ARG EXTRA_BUNDLE_CONFIG="without 'test'"

RUN apk add bash curl mysql mysql-client && \
  curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-8/cfg/setup/bash.alpine.sh' |  bash && \
  apk upgrade && \
  apk add build-base mysql-dev isc-kea-admin isc-kea-perfdhcp isc-kea-dhcp4 isc-kea-ctrl-agent isc-kea-hook-lease-cmds isc-kea-hook-stat-cmds isc-kea-hook-ha && \
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
COPY ./config_api.json ./config_api.json
COPY ./local_development_config.json ./test_config.json
COPY ./metrics ./metrics
COPY ./control-agent-config.json /etc/kea/control-agent-config.json

RUN cd metrics && \
  bundle config set no-cache 'true' ${EXTRA_BUNDLE_CONFIG} && \
  bundle install

EXPOSE 67/udp
EXPOSE 68/udp
EXPOSE 8000

CMD ["./bootstrap.sh"]

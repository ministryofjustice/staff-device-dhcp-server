FROM ruby:3.2.2-alpine3.17

ARG EXTRA_BUNDLE_CONFIG="without 'test'"

RUN apk add bash curl mysql mysql-client && \
  curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-2-4/setup.alpine.sh' |  bash && \
  apk upgrade && \
  apk search isc-kea && \
  apk add --no-cache build-base mysql-dev isc-kea
  

RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
  unzip awscliv2.zip && \
  aws/install && \
  rm -rf awscliv2.zip aws /usr/local/aws-cli/v2/*/dist/aws_completer /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index /usr/local/aws-cli/v2/*/dist/awscli/examples && \
  rm -rf /var/cache/apk/*

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

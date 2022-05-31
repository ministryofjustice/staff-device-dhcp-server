FROM alpine:3.13

ENV GLIBC_VER=2.31-r0

RUN apk add bash curl mysql mysql-client && \
  curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-2-1/rsa.CC39698D5EDFF644.key' > /etc/apk/keys/kea-2-1@isc-CC39698D5EDFF644.rsa.pub && \
  curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-2-1/config.alpine.txt?distro=alpine&codename=v3.13' >> /etc/apk/repositories && \
  # curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-2-1/setup.alpine.sh' |  bash && \
  apk update &&  \
  apk upgrade && \
  apk add build-base mysql-dev isc-kea-admin isc-kea-perfdhcp isc-kea-dhcp4 isc-kea-ctrl-agent isc-kea-hook-lease-cmds isc-kea-hook-stat-cmds isc-kea-hook-ha && \
  curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
  apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk && \
  rm glibc-${GLIBC_VER}.apk && \
  rm glibc-bin-${GLIBC_VER}.apk && \
  rm -rf /var/cache/apk/*


EXPOSE 67/udp
EXPOSE 68/udp
EXPOSE 8000

CMD ["sleep infinity"]

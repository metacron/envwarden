FROM node:11-alpine

ARG BITWARDEN_CLI_VERSION=1.13.3

LABEL maintainer="envwarden"

RUN apk update && apk add bash wget jq

RUN npm install -g @bitwarden/cli@${BITWARDEN_CLI_VERSION}

ADD envwarden /usr/local/bin

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["envwarden"]

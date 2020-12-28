FROM node:12-buster-slim

ARG BITWARDEN_CLI_VERSION=1.13.3

LABEL maintainer="metacron"
LABEL org.opencontainers.image.source https://github.com/metacron/envwarden

RUN apt-get update -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	wget jq

RUN npm install -g @bitwarden/cli@${BITWARDEN_CLI_VERSION}

ADD envwarden /usr/local/bin

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["envwarden"]

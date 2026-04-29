ARG ALPINE_BASE_VERSION=3

FROM alpine:$ALPINE_BASE_VERSION

ARG SKOPEO_VERSION=1.20.0
ARG KUBECTL_VERSION=1.34.2

COPY *.sh /usr/local/bin/

RUN apk add --no-cache bash "skopeo~=${SKOPEO_VERSION}" "kubectl~=${KUBECTL_VERSION}" && \
    adduser -D -u 1000 mirror && \
    chmod +x /usr/local/bin/mirror.sh && \
    chmod +x /usr/local/bin/scrape.sh

USER mirror

ENTRYPOINT ["/usr/local/bin/mirror.sh"]

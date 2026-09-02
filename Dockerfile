ARG FIVEM_NUM=35245
ARG FIVEM_VER=35245-6efb47dff473c0e2a12fb50b08d74c0eb24a50d5
ARG DATA_VER=32d98e7524b952faf8b220d719615b0346b0a6cc

FROM alpine:3.23 AS builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output

RUN wget -O- https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/cfx-server-data /output/usr/local/share \
 && wget -O- https://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C opt/cfx-server-data

ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint

RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER

LABEL org.opencontainers.image.title="FiveM" \
      org.opencontainers.image.url="https://fivem.net" \
      org.opencontainers.image.source="https://github.com/Enz0Z/fivem-docker" \
      org.opencontainers.image.description="FXServer (FiveM) dedicated server, auto-updated daily to the recommended artifact." \
      org.opencontainers.image.version=${FIVEM_NUM} \
      fivem.version=${FIVEM_VER} \
      fivem.data_version=${DATA_VER}

COPY --from=builder /output/ /
RUN apk add --no-cache tini

WORKDIR /config
EXPOSE 30120

# Default to an empty CMD, so we can use it to add separate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]

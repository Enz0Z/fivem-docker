# Pinned versions live in legacy.env / enhanced.env; build with
#   docker build $(sed 's/^/--build-arg /' legacy.env) .
ARG FIVEM_NUM
ARG FIVEM_URL
ARG DATA_VER=c6afa3909c763e3327ed76825e78453286c99f05

FROM alpine:3.23 AS builder

ARG FIVEM_URL
ARG DATA_VER

WORKDIR /fx

# Both artifacts ship an alpine/ rootfs; legacy names it alpine/, Enhanced ./alpine/, so extract whole and COPY alpine/ later.
RUN : "${FIVEM_URL:?set --build-arg FIVEM_URL (see legacy.env / enhanced.env)}" \
 && wget -O- "${FIVEM_URL}" \
        | tar xJ --exclude alpine/dev --exclude alpine/proc \
                 --exclude alpine/run --exclude alpine/sys \
 && mkdir -p alpine/opt/cfx-server-data alpine/usr/local/share \
 && wget -O- https://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C alpine/opt/cfx-server-data

ADD server.cfg alpine/opt/cfx-server-data
ADD entrypoint alpine/usr/bin/entrypoint

RUN chmod +x alpine/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_URL
ARG FIVEM_NUM
ARG DATA_VER

LABEL org.opencontainers.image.title="FiveM" \
      org.opencontainers.image.url="https://fivem.net" \
      org.opencontainers.image.source="https://github.com/Enz0Z/fivem-docker" \
      org.opencontainers.image.description="FXServer (FiveM) dedicated server, auto-updated daily to the recommended artifact." \
      org.opencontainers.image.version=${FIVEM_NUM} \
      fivem.download=${FIVEM_URL} \
      fivem.data_version=${DATA_VER}

COPY --from=builder /fx/alpine/ /
RUN apk add --no-cache tini

WORKDIR /config
EXPOSE 30120

# Default to an empty CMD, so we can use it to add separate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]

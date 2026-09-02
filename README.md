# fivem-docker

[![update](https://github.com/Enz0Z/fivem-docker/actions/workflows/update.yml/badge.svg)](https://github.com/Enz0Z/fivem-docker/actions/workflows/update.yml)

Docker image for a FiveM (FXServer) dedicated server, based on [spritsail/fivem](https://github.com/spritsail/fivem).
A GitHub Actions workflow checks the FiveM artifact feed **every day** and, when a new `recommended` build is published,
bumps the Dockerfile, commits it and pushes a fresh image to `ghcr.io/enz0z/fivem-docker`.

Tags: `latest` and the FiveM build number (e.g. `35245`).

## Usage

```sh
docker run -d \
  --name fivem \
  --restart=on-failure \
  -e LICENSE_KEY=<your-license-here> \
  -p 30120:30120 \
  -p 30120:30120/udp \
  -v /volumes/fivem:/config \
  -ti \
  ghcr.io/enz0z/fivem-docker
```

`-ti` is required or the container crashes on startup. A `docker-compose.yml` is provided too.

On first run the default `cfx-server-data` resources and `server.cfg` are copied into `/config`; stop the container and edit them there.

### txAdmin

Set `NO_DEFAULT_CONFIG=1`, expose port `40120` and mount `/txData` to persist its data. Do not set `LICENSE_KEY` in that mode, configure it in the txAdmin UI.

### Environment variables

- `LICENSE_KEY` - required, get one at https://keymaster.fivem.net
- `RCON_PASSWORD` - RCON password. Random 16 chars if unset. Only used when generating the default config.
- `NO_DEFAULT_CONFIG` - disable `+exec /config/server.cfg`. Required for txAdmin.
- `NO_LICENSE_KEY` - do not pass the license key via environment (useful if it lives in `server.cfg`).
- `NO_ONESYNC` - do not enable OneSync in the default args.

## Manual update

```sh
./update.sh && git commit -am "Update FiveM" && git push
```

## Credits

The Dockerfile, entrypoint and default `server.cfg` come from [spritsail/fivem](https://github.com/spritsail/fivem),
written and maintained by the [Spritsail](https://github.com/spritsail) team (Joe Groocock, Adam Dodman and contributors).
This repo only adds the daily auto-update workflow on top of their work. All credit for the image itself goes to them.

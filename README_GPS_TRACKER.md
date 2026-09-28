# GPS Tracker integration

Infrastructure now contains the GPS Tracker service at `mapa.serveftp.org`.

## DNS

Create/verify an A record:

`mapa.serveftp.org` -> the public IPv4 address reaching this Infrastructure host.

TCP ports 80 and 443 must reach Traefik. The existing Traefik ports are used; no additional public port is required.

## Environment

Add these values to the real `.env` (do not commit the real secrets):

```dotenv
GPS_DOMAIN=mapa.serveftp.org
GPS_API_TOKEN=<long-random-token>
GPS_DEFAULT_DEVICE_NAME=Tracker 1
GPS_ADMIN_USER=admin
GPS_ADMIN_PASSWORD=<strong-password>
IP_GPS_TRACKER=10.40.0.20
GPS_DATA_DIR=${DATA_DIR}/gps-tracker
```

Also set a real `TRAEFIK_ACME_EMAIL`.

## Deployment

The normal Infrastructure deployment will copy `gps-tracker/` and include `compose/50-gps-tracker.yml`.

The first deployment builds the local image. Persistent SQLite data is stored in `${GPS_DATA_DIR}`.

Traefik obtains the TLS certificate for `mapa.serveftp.org` through Let's Encrypt HTTP-01 on port 80.

## Tracker API

`GPS_API_TOKEN` registers exactly one tracker device automatically on first
startup. The ESP32 should send a batch with:

`POST https://mapa.serveftp.org/api/ingest`

and header:

`X-GPS-Token: <token of the device>`

The body contains the GPS points already collected into the SD/LTE batch. The server does not require one HTTP request per GPS second.

### Adding more trackers

The service supports multiple trackers at once. Register additional devices
from the web UI ("+ Přidat tracker") or via `POST /api/devices` (HTTP Basic
auth with `GPS_ADMIN_USER`/`GPS_ADMIN_PASSWORD`); each call returns a new
token, shown only once. Configure each tracker's firmware with its own
token - see `gps-tracker/README.md` for the full API.

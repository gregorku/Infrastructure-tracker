# GPS Tracker server

This service receives GPS batches from one or more ESP32 trackers, stores
them in SQLite and exposes a simple Leaflet map. Each tracker is a
registered "device" with its own upload token, so several trackers can
share the same server and be told apart on the map.

## Endpoints

- `GET /` – map and route list
- `GET /health` – health check
- `GET /api/routes` – route list (optional `?device_id=` filter)
- `GET /api/routes/{id}` – route and GPS points
- `POST /api/ingest` – tracker upload; requires `X-GPS-Token`
- `PATCH /api/routes/{id}` – rename; HTTP Basic authentication
- `DELETE /api/routes/{id}` – delete route and points; HTTP Basic authentication
- `GET /api/devices` – list registered trackers; HTTP Basic authentication
- `POST /api/devices` – register a new tracker, `{"name": "..."}`; HTTP Basic
  authentication. Returns `{"id", "name", "token"}` - **the token is only
  ever shown in this response**, write it down.
- `PATCH /api/devices/{id}` – rename a tracker; HTTP Basic authentication
- `DELETE /api/devices/{id}` – remove a tracker registration (its past
  routes are kept, just no longer attributed to a device); HTTP Basic
  authentication

## Trackers (multi-device)

On first startup the server creates one device automatically, named after
`GPS_DEFAULT_DEVICE_NAME` (default `Tracker 1`) with the token from
`GPS_API_TOKEN`. This keeps a single-tracker setup working with zero extra
steps.

To add another tracker, use the "+ Přidat tracker" button in the web UI (or
`POST /api/devices` directly) and configure the new device's firmware with
the returned token. Each device authenticates independently via its own
`X-GPS-Token`; routes and the map sidebar filter can be split by device.

## Tracker upload format

```json
{
  "name": "Cesta 2026-09-26",
  "points": [
    {
      "timestamp": "2026-09-26T17:31:49Z",
      "latitude": 50.501299,
      "longitude": 13.441605,
      "altitude": 328.6,
      "speed": 0.0,
      "satellites": 12,
      "hdop": 1.2,
      "battery_adc": 2383.9,
      "battery_voltage": 4.180,
      "battery_percent": 98.0
    }
  ]
}
```

The server groups incoming batches into a route per device and UTC calendar
day. A route can be deleted before a trip if it was only created during
battery/testing preparation.

## Environment variables

| Variable                | Purpose                                              |
|--------------------------|-------------------------------------------------------|
| `GPS_DATA_DIR`            | Directory for the SQLite database                     |
| `GPS_API_TOKEN`           | Token for the first, auto-created tracker device      |
| `GPS_DEFAULT_DEVICE_NAME` | Name of that first device (default `Tracker 1`)       |
| `GPS_ADMIN_USER`          | HTTP Basic user for rename/delete/device management    |
| `GPS_ADMIN_PASSWORD`      | HTTP Basic password for the same                       |

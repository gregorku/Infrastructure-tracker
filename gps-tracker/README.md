# GPS Tracker server

This service receives GPS batches from the ESP32 tracker, stores them in SQLite and exposes a simple Leaflet map.

## Endpoints

- `GET /` – map and route list
- `GET /health` – health check
- `GET /api/routes` – route list
- `GET /api/routes/{id}` – route and GPS points
- `POST /api/ingest` – tracker upload; requires `X-GPS-Token`
- `PATCH /api/routes/{id}` – rename; HTTP Basic authentication
- `DELETE /api/routes/{id}` – delete route and points; HTTP Basic authentication

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

The server groups incoming batches into a route for the same UTC calendar day. A route can be deleted before a trip if it was only created during battery/testing preparation.

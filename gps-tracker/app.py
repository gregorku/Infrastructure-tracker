import base64
import datetime as dt
import hmac
import os
import secrets
import sqlite3
from pathlib import Path
from typing import Any

from fastapi import FastAPI, Header, HTTPException, Request
from pydantic import BaseModel
from fastapi.responses import FileResponse

DATA_DIR = Path(os.getenv("GPS_DATA_DIR", "/data"))
DB_PATH = DATA_DIR / "gps.sqlite3"

# Token/name used to seed the very first tracker device on first startup.
# Every device after that gets its own token, issued through /api/devices.
BOOTSTRAP_TOKEN = os.getenv("GPS_API_TOKEN", "change-me")
BOOTSTRAP_DEVICE_NAME = os.getenv("GPS_DEFAULT_DEVICE_NAME", "Tracker 1")

ADMIN_USER = os.getenv("GPS_ADMIN_USER", "admin")
ADMIN_PASSWORD = os.getenv("GPS_ADMIN_PASSWORD", "change-me")

app = FastAPI(title="GPS Tracker", docs_url="/api/docs", redoc_url=None)


def db():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    with db() as c:
        c.executescript("""
        CREATE TABLE IF NOT EXISTS devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            token TEXT NOT NULL UNIQUE,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS routes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL,
            name TEXT NOT NULL,
            started_at TEXT,
            ended_at TEXT,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            route_id INTEGER NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
            timestamp TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            altitude REAL,
            speed REAL,
            satellites INTEGER,
            hdop REAL,
            battery_adc REAL,
            battery_voltage REAL,
            battery_percent REAL
        );
        CREATE INDEX IF NOT EXISTS idx_points_route_time ON points(route_id, timestamp);
        """)

        # Migration: routes table may predate the device_id column
        # (single-tracker deployments created before this feature).
        # Must happen before the device_id index is created below.
        cols = [row["name"] for row in c.execute("PRAGMA table_info(routes)")]
        if "device_id" not in cols:
            c.execute("ALTER TABLE routes ADD COLUMN device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL")

        c.execute("CREATE INDEX IF NOT EXISTS idx_routes_device ON routes(device_id)")

        # Seed (or recover) a default device from GPS_API_TOKEN so a
        # single-tracker setup keeps working with zero extra configuration.
        existing = c.execute("SELECT id FROM devices WHERE token=?", (BOOTSTRAP_TOKEN,)).fetchone()
        if not existing:
            any_device = c.execute("SELECT id FROM devices LIMIT 1").fetchone()
            if not any_device:
                c.execute(
                    "INSERT INTO devices(name, token) VALUES(?,?)",
                    (BOOTSTRAP_DEVICE_NAME, BOOTSTRAP_TOKEN),
                )

        # Backfill: assign any pre-existing device-less routes to the
        # oldest device so old data stays visible after upgrading.
        first_device = c.execute("SELECT id FROM devices ORDER BY id LIMIT 1").fetchone()
        if first_device:
            c.execute(
                "UPDATE routes SET device_id=? WHERE device_id IS NULL",
                (first_device["id"],),
            )


@app.on_event("startup")
def startup():
    init_db()


def admin_ok(auth: str | None) -> bool:
    if not auth or not auth.lower().startswith("basic "):
        return False
    try:
        raw = base64.b64decode(auth.split(" ", 1)[1]).decode()
        user, password = raw.split(":", 1)
    except Exception:
        return False
    return hmac.compare_digest(user, ADMIN_USER) and hmac.compare_digest(password, ADMIN_PASSWORD)


def require_admin(authorization: str | None):
    if not admin_ok(authorization):
        raise HTTPException(401, "Administrator authentication required", headers={"WWW-Authenticate": "Basic"})


def device_for_token(c: sqlite3.Connection, token: str | None) -> sqlite3.Row | None:
    if not token:
        return None
    for row in c.execute("SELECT id, name, token FROM devices").fetchall():
        if hmac.compare_digest(row["token"], token):
            return row
    return None


@app.get("/health")
def health():
    return {"status": "ok"}


###############################################################################
# Devices (tracker registry) - admin only
###############################################################################

class DeviceCreate(BaseModel):
    name: str


class DeviceRename(BaseModel):
    name: str


@app.get("/api/devices")
def list_devices(authorization: str | None = Header(default=None)):
    require_admin(authorization)
    with db() as c:
        rows = c.execute("""
            SELECT d.id, d.name, d.created_at, COUNT(r.id) AS routes
            FROM devices d LEFT JOIN routes r ON r.device_id = d.id
            GROUP BY d.id ORDER BY d.id
        """).fetchall()
    # Tokens are never returned once created - only at creation time below.
    return [dict(r) for r in rows]


@app.post("/api/devices")
def create_device(payload: DeviceCreate, authorization: str | None = Header(default=None)):
    require_admin(authorization)
    name = payload.name.strip()
    if not name:
        raise HTTPException(400, "Name cannot be empty")
    token = secrets.token_urlsafe(24)
    with db() as c:
        cur = c.execute("INSERT INTO devices(name, token) VALUES(?,?)", (name, token))
        device_id = cur.lastrowid
    return {"id": device_id, "name": name, "token": token}


@app.patch("/api/devices/{device_id}")
def rename_device(device_id: int, payload: DeviceRename, authorization: str | None = Header(default=None)):
    require_admin(authorization)
    name = payload.name.strip()
    if not name:
        raise HTTPException(400, "Name cannot be empty")
    with db() as c:
        if not c.execute("SELECT 1 FROM devices WHERE id=?", (device_id,)).fetchone():
            raise HTTPException(404, "Device not found")
        c.execute("UPDATE devices SET name=? WHERE id=?", (name, device_id))
    return {"ok": True}


@app.delete("/api/devices/{device_id}")
def delete_device(device_id: int, authorization: str | None = Header(default=None)):
    require_admin(authorization)
    with db() as c:
        if not c.execute("SELECT 1 FROM devices WHERE id=?", (device_id,)).fetchone():
            raise HTTPException(404, "Device not found")
        # Routes are kept (device_id is set to NULL by the foreign key);
        # only the device/token registration itself is removed.
        c.execute("DELETE FROM devices WHERE id=?", (device_id,))
    return {"ok": True}


###############################################################################
# Routes
###############################################################################

@app.get("/api/routes")
def routes(device_id: int | None = None):
    query = """
        SELECT r.id, r.device_id, d.name AS device_name,
               r.name, r.started_at, r.ended_at, r.created_at,
               COUNT(p.id) AS points,
               MIN(p.latitude) AS min_lat, MAX(p.latitude) AS max_lat,
               MIN(p.longitude) AS min_lon, MAX(p.longitude) AS max_lon
        FROM routes r
        LEFT JOIN points p ON p.route_id = r.id
        LEFT JOIN devices d ON d.id = r.device_id
    """
    params: tuple = ()
    if device_id is not None:
        query += " WHERE r.device_id = ?"
        params = (device_id,)
    query += " GROUP BY r.id ORDER BY COALESCE(r.started_at, r.created_at) DESC"

    with db() as c:
        rows = c.execute(query, params).fetchall()
    return [dict(r) for r in rows]


@app.get("/api/routes/{route_id}")
def route(route_id: int):
    with db() as c:
        r = c.execute("""
            SELECT r.*, d.name AS device_name
            FROM routes r LEFT JOIN devices d ON d.id = r.device_id
            WHERE r.id=?
        """, (route_id,)).fetchone()
        if not r:
            raise HTTPException(404, "Route not found")
        pts = c.execute("""
            SELECT timestamp, latitude, longitude, altitude, speed, satellites,
                   hdop, battery_adc, battery_voltage, battery_percent
            FROM points WHERE route_id=? ORDER BY timestamp, id
        """, (route_id,)).fetchall()
    return {"route": dict(r), "points": [dict(p) for p in pts]}


@app.post("/api/ingest")
async def ingest(request: Request, x_gps_token: str | None = Header(default=None)):
    with db() as c:
        device = device_for_token(c, x_gps_token)
    if not device:
        raise HTTPException(401, "Invalid GPS token")

    payload: Any = await request.json()
    points = payload.get("points") if isinstance(payload, dict) else payload
    if not isinstance(points, list) or not points:
        raise HTTPException(400, "points must be a non-empty list")

    cleaned = []
    for p in points:
        try:
            cleaned.append((
                str(p["timestamp"]), float(p["latitude"]), float(p["longitude"]),
                float(p.get("altitude", 0)), float(p.get("speed", 0)),
                int(p.get("satellites", 0)), float(p.get("hdop", 0)),
                float(p.get("battery_adc", 0)), float(p.get("battery_voltage", 0)),
                float(p.get("battery_percent", 0)),
            ))
        except (KeyError, TypeError, ValueError) as e:
            raise HTTPException(400, f"Invalid point: {e}")

    start = cleaned[0][0]
    end = cleaned[-1][0]
    date = start[:10] if len(start) >= 10 else dt.datetime.now(dt.timezone.utc).date().isoformat()
    name = payload.get("name") if isinstance(payload, dict) else None
    if not name:
        name = f"{device['name']} - {date}"

    with db() as c:
        # Continue the current route for the same device and calendar day;
        # this keeps LTE batches from the same tracker together.
        r = c.execute(
            "SELECT id FROM routes WHERE device_id=? AND started_at LIKE ? ORDER BY id DESC LIMIT 1",
            (device["id"], date + "%"),
        ).fetchone()
        if r:
            route_id = r["id"]
            c.execute("UPDATE routes SET ended_at=? WHERE id=?", (end, route_id))
        else:
            cur = c.execute(
                "INSERT INTO routes(device_id, name, started_at, ended_at) VALUES(?,?,?,?)",
                (device["id"], name, start, end),
            )
            route_id = cur.lastrowid
        c.executemany("""
            INSERT INTO points(route_id,timestamp,latitude,longitude,altitude,speed,satellites,hdop,
                               battery_adc,battery_voltage,battery_percent)
            VALUES(?,?,?,?,?,?,?,?,?,?,?)
        """, [(route_id, *p) for p in cleaned])
    return {"ok": True, "device": device["name"], "route_id": route_id, "points": len(cleaned)}


class RenamePayload(BaseModel):
    name: str


@app.patch("/api/routes/{route_id}")
def rename_route(route_id: int, payload: RenamePayload, authorization: str | None = Header(default=None)):
    require_admin(authorization)
    name = payload.name.strip()
    if not name:
        raise HTTPException(400, "Name cannot be empty")
    with db() as c:
        if not c.execute("SELECT 1 FROM routes WHERE id=?", (route_id,)).fetchone():
            raise HTTPException(404, "Route not found")
        c.execute("UPDATE routes SET name=? WHERE id=?", (name, route_id))
    return {"ok": True}


@app.delete("/api/routes/{route_id}")
def delete_route(route_id: int, authorization: str | None = Header(default=None)):
    require_admin(authorization)
    with db() as c:
        if not c.execute("SELECT 1 FROM routes WHERE id=?", (route_id,)).fetchone():
            raise HTTPException(404, "Route not found")
        c.execute("DELETE FROM points WHERE route_id=?", (route_id,))
        c.execute("DELETE FROM routes WHERE id=?", (route_id,))
    return {"ok": True}


@app.get("/", include_in_schema=False)
def index():
    return FileResponse("/app/static/index.html")

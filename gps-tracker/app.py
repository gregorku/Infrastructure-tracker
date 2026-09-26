import base64
import datetime as dt
import hmac
import os
import sqlite3
from pathlib import Path
from typing import Any

from fastapi import FastAPI, Header, HTTPException, Request
from pydantic import BaseModel
from fastapi.responses import FileResponse

DATA_DIR = Path(os.getenv("GPS_DATA_DIR", "/data"))
DB_PATH = DATA_DIR / "gps.sqlite3"
API_TOKEN = os.getenv("GPS_API_TOKEN", "change-me")
ADMIN_USER = os.getenv("GPS_ADMIN_USER", "admin")
ADMIN_PASSWORD = os.getenv("GPS_ADMIN_PASSWORD", "change-me")

app = FastAPI(title="GPS Tracker", docs_url="/api/docs", redoc_url=None)


def db():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    with db() as c:
        c.executescript("""
        CREATE TABLE IF NOT EXISTS routes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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


def gps_token_ok(token: str | None) -> bool:
    return token is not None and hmac.compare_digest(token, API_TOKEN)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/api/routes")
def routes():
    with db() as c:
        rows = c.execute("""
            SELECT r.id, r.name, r.started_at, r.ended_at, r.created_at,
                   COUNT(p.id) AS points,
                   MIN(p.latitude) AS min_lat, MAX(p.latitude) AS max_lat,
                   MIN(p.longitude) AS min_lon, MAX(p.longitude) AS max_lon
            FROM routes r LEFT JOIN points p ON p.route_id=r.id
            GROUP BY r.id ORDER BY COALESCE(r.started_at,r.created_at) DESC
        """).fetchall()
    return [dict(r) for r in rows]


@app.get("/api/routes/{route_id}")
def route(route_id: int):
    with db() as c:
        r = c.execute("SELECT * FROM routes WHERE id=?", (route_id,)).fetchone()
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
    if not gps_token_ok(x_gps_token):
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
        name = f"Cesta {date}"

    with db() as c:
        # Continue the current route for the same calendar day; this keeps LTE batches together.
        r = c.execute("SELECT id FROM routes WHERE started_at LIKE ? ORDER BY id DESC LIMIT 1", (date + "%",)).fetchone()
        if r:
            route_id = r["id"]
            c.execute("UPDATE routes SET ended_at=? WHERE id=?", (end, route_id))
        else:
            cur = c.execute("INSERT INTO routes(name, started_at, ended_at) VALUES(?,?,?)", (name, start, end))
            route_id = cur.lastrowid
        c.executemany("""
            INSERT INTO points(route_id,timestamp,latitude,longitude,altitude,speed,satellites,hdop,
                               battery_adc,battery_voltage,battery_percent)
            VALUES(?,?,?,?,?,?,?,?,?,?,?)
        """, [(route_id, *p) for p in cleaned])
    return {"ok": True, "route_id": route_id, "points": len(cleaned)}


@app.patch("/api/routes/{route_id}")
class RenamePayload(BaseModel):
    name: str


@app.patch("/api/routes/{route_id}")
def rename_route(route_id: int, payload: RenamePayload, authorization: str | None = Header(default=None)):
    if not admin_ok(authorization):
        raise HTTPException(401, "Administrator authentication required", headers={"WWW-Authenticate": "Basic"})
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
    if not admin_ok(authorization):
        raise HTTPException(401, "Administrator authentication required", headers={"WWW-Authenticate": "Basic"})
    with db() as c:
        if not c.execute("SELECT 1 FROM routes WHERE id=?", (route_id,)).fetchone():
            raise HTTPException(404, "Route not found")
        c.execute("DELETE FROM points WHERE route_id=?", (route_id,))
        c.execute("DELETE FROM routes WHERE id=?", (route_id,))
    return {"ok": True}


@app.get("/", include_in_schema=False)
def index():
    return FileResponse("/app/static/index.html")

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, timedelta

import math
import json
import secrets
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from passlib.context import CryptContext

from database import get_db_connection


# ============================================================
# FASTAPI APP
# ============================================================

app = FastAPI(
    title="SmartCharge EV Backend",
    description="Smart EV Charging Allocation and Real-Time Queue Management System",
    version="1.0.0"
)


# ============================================================
# CORS
# IMPORTANT FOR FLUTTER WEB / CHROME
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# PASSWORD HASHING
# bcrypt==4.0.1
# ============================================================

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

# Demo/local OTP store. For production, replace demo_otp delivery with a real
# email/SMS provider and store OTPs in a database or secure cache.
password_reset_otps = {}



# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "message": "SmartCharge EV Backend is running",
        "status": "success",
        "version": "1.0.0"
    }


# ============================================================
# TEST DATABASE
# ============================================================

@app.get("/test-db")
def test_db():

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT DATABASE()")
        result = cursor.fetchone()

        return {
            "message": "Database connection successful",
            "database": result
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Database connection failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# PYDANTIC MODELS
# ============================================================

class RegisterRequest(BaseModel):

    name: str = Field(min_length=2, max_length=100)

    email: str = Field(
        min_length=5,
        max_length=100
    )

    phone: Optional[str] = Field(
        default=None,
        max_length=15
    )

    password: str = Field(
        min_length=6,
        max_length=100
    )


class LoginRequest(BaseModel):

    email: str

    password: str


class ForgotPasswordRequest(BaseModel):
    identifier: str = Field(min_length=3, max_length=100)
    method: str = Field(default="email")


class ResetPasswordRequest(BaseModel):
    identifier: str = Field(min_length=3, max_length=100)
    method: str = Field(default="email")
    otp: str = Field(min_length=6, max_length=6)
    new_password: str = Field(min_length=6, max_length=100)


class VehicleRequest(BaseModel):

    vehicle_number: str

    model: Optional[str] = None

    battery_capacity: Optional[float] = None


class ChargingRequest(BaseModel):

    user_id: int

    vehicle_id: int

    station_id: int

    battery_now: float

    battery_required: float

    arrival_time: datetime

    departure_time: datetime


# ============================================================
# AUTH - REGISTER
# ============================================================

@app.post("/auth/register")
def register_user(request: RegisterRequest):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # ----------------------------------------------------
        # CHECK EMAIL
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT user_id
            FROM users
            WHERE email = %s
            """,
            (request.email,)
        )

        existing_user = cursor.fetchone()

        if existing_user:

            raise HTTPException(
                status_code=409,
                detail="Email already registered. Please login."
            )

        # ----------------------------------------------------
        # HASH PASSWORD
        # ----------------------------------------------------

        password_hash = pwd_context.hash(
            request.password
        )

        # ----------------------------------------------------
        # INSERT USER
        # ----------------------------------------------------

        cursor.execute(
            """
            INSERT INTO users
            (
                name,
                email,
                phone,
                password_hash,
                role
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                'user'
            )
            """,
            (
                request.name,
                request.email,
                request.phone,
                password_hash
            )
        )

        conn.commit()

        user_id = cursor.lastrowid

        return {
            "message": "Registration successful",
            "user_id": user_id,
            "name": request.name,
            "email": request.email,
            "phone": request.phone,
            "role": "user"
        }

    except HTTPException:

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=f"Registration failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# AUTH - LOGIN
# ============================================================

@app.post("/auth/login")
def login_user(request: LoginRequest):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                user_id,
                name,
                email,
                phone,
                password_hash,
                role
            FROM users
            WHERE email = %s
            """,
            (request.email,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=401,
                detail="Invalid email or password"
            )

        # ----------------------------------------------------
        # VERIFY PASSWORD
        # ----------------------------------------------------

        try:

            password_correct = pwd_context.verify(
                request.password,
                user["password_hash"]
            )

        except Exception:

            password_correct = False

        if not password_correct:

            raise HTTPException(
                status_code=401,
                detail="Invalid email or password"
            )

        return {
            "message": "Login successful",
            "user_id": user["user_id"],
            "name": user["name"],
            "email": user["email"],
            "phone": user["phone"],
            "role": user["role"]
        }

    except HTTPException:

        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Login failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# AUTH - FORGOT PASSWORD / OTP
# ============================================================

@app.post("/auth/forgot-password")
def forgot_password(request: ForgotPasswordRequest):
    method = request.method.strip().lower()
    identifier = request.identifier.strip()

    if method not in ("email", "phone"):
        raise HTTPException(status_code=400, detail="Method must be email or phone")

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        if method == "email":
            cursor.execute(
                "SELECT user_id, email, phone FROM users WHERE email = %s LIMIT 1",
                (identifier,)
            )
        else:
            cursor.execute(
                "SELECT user_id, email, phone FROM users WHERE phone = %s LIMIT 1",
                (identifier,)
            )

        user = cursor.fetchone()
        if not user:
            raise HTTPException(
                status_code=404,
                detail="No account found with this email/phone number"
            )

        otp = f"{secrets.randbelow(1000000):06d}"
        expires_at = datetime.now() + timedelta(minutes=5)
        password_reset_otps[(method, identifier)] = {
            "user_id": user["user_id"],
            "otp": otp,
            "expires_at": expires_at,
            "attempts": 0,
        }

        # Local development/demo delivery.
        print("=" * 60)
        print(f"SMARTCHARGE PASSWORD RESET OTP ({method.upper()})")
        print(f"User ID : {user['user_id']}")
        print(f"Target  : {identifier}")
        print(f"OTP     : {otp}")
        print("Valid for: 5 minutes")
        print("=" * 60)

        return {
            "message": f"OTP generated for registered {method}",
            "method": method,
            "expires_in_minutes": 5,
            # Demo only. Remove demo_otp before production deployment.
            "demo_otp": otp,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Forgot password failed: {str(e)}"
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


@app.post("/auth/reset-password")
def reset_password(request: ResetPasswordRequest):
    method = request.method.strip().lower()
    identifier = request.identifier.strip()

    if method not in ("email", "phone"):
        raise HTTPException(status_code=400, detail="Method must be email or phone")

    key = (method, identifier)
    reset_data = password_reset_otps.get(key)

    if not reset_data:
        raise HTTPException(
            status_code=400,
            detail="OTP not requested or already used. Please request a new OTP."
        )

    if datetime.now() > reset_data["expires_at"]:
        password_reset_otps.pop(key, None)
        raise HTTPException(status_code=400, detail="OTP expired. Please request a new OTP.")

    if reset_data["attempts"] >= 5:
        password_reset_otps.pop(key, None)
        raise HTTPException(status_code=429, detail="Too many wrong OTP attempts. Request a new OTP.")

    if request.otp != reset_data["otp"]:
        reset_data["attempts"] += 1
        raise HTTPException(status_code=400, detail="Invalid OTP")

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        password_hash = pwd_context.hash(request.new_password)
        cursor.execute(
            "UPDATE users SET password_hash = %s WHERE user_id = %s",
            (password_hash, reset_data["user_id"])
        )
        conn.commit()
        password_reset_otps.pop(key, None)

        return {
            "message": "Password reset successful",
            "user_id": reset_data["user_id"],
        }

    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Password reset failed: {str(e)}"
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# BEE STATION SEARCH BY ENTERED LOCATION
# ============================================================

@app.get("/stations/search-location")
def search_stations_by_location(
    query: str,
    radius_km: float = Query(default=10, ge=1, le=100)
):
    query = query.strip()
    if not query:
        raise HTTPException(status_code=400, detail="Location cannot be empty")

    try:
        params = urlencode({
            "q": f"{query}, Andhra Pradesh, India",
            "format": "json",
            "limit": 1,
            "countrycodes": "in",
        })
        url = f"https://nominatim.openstreetmap.org/search?{params}"
        req = Request(
            url,
            headers={"User-Agent": "SmartChargeEV/1.0"}
        )

        with urlopen(req, timeout=10) as response:
            geocoded = json.loads(response.read().decode("utf-8"))

        if not geocoded:
            raise HTTPException(
                status_code=404,
                detail=f"Could not find location: {query}"
            )

        latitude = float(geocoded[0]["lat"])
        longitude = float(geocoded[0]["lon"])
        display_name = geocoded[0].get("display_name", query)

        # Reuse the existing BEE dataset + Haversine distance logic.
        result = nearby_stations(
            latitude=latitude,
            longitude=longitude,
            radius_km=radius_km,
        )

        return {
            "source": "BEE EV Charging Station Dataset",
            "search_location": query,
            "resolved_location": display_name,
            "latitude": latitude,
            "longitude": longitude,
            "radius_km": radius_km,
            "station_count": len(result["stations"]),
            "stations": result["stations"],
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Location search failed: {str(e)}"
        )


# ============================================================
# GET USER
# ============================================================

@app.get("/users/{user_id}")
def get_user(user_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                user_id,
                name,
                email,
                phone,
                role,
                created_at
            FROM users
            WHERE user_id = %s
            """,
            (user_id,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        return user

    except HTTPException:

        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# VEHICLES - ADD
# ============================================================

@app.post("/users/{user_id}/vehicles")
def add_vehicle(
    user_id: int,
    vehicle: VehicleRequest
):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Check user

        cursor.execute(
            """
            SELECT user_id
            FROM users
            WHERE user_id = %s
            """,
            (user_id,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        # Check vehicle number

        cursor.execute(
            """
            SELECT vehicle_id
            FROM vehicles
            WHERE vehicle_number = %s
            """,
            (vehicle.vehicle_number,)
        )

        existing = cursor.fetchone()

        if existing:

            raise HTTPException(
                status_code=409,
                detail="Vehicle number already registered"
            )

        cursor.execute(
            """
            INSERT INTO vehicles
            (
                user_id,
                vehicle_number,
                model,
                battery_capacity
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s
            )
            """,
            (
                user_id,
                vehicle.vehicle_number,
                vehicle.model,
                vehicle.battery_capacity
            )
        )

        conn.commit()

        return {
            "message": "Vehicle added successfully",
            "vehicle_id": cursor.lastrowid
        }

    except HTTPException:

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# GET USER VEHICLES
# ============================================================

@app.get("/users/{user_id}/vehicles")
def get_user_vehicles(user_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                vehicle_id,
                user_id,
                vehicle_number,
                model,
                battery_capacity
            FROM vehicles
            WHERE user_id = %s
            ORDER BY vehicle_id DESC
            """,
            (user_id,)
        )

        vehicles = cursor.fetchall()

        return vehicles

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# INTERNAL STATIONS
# ============================================================

@app.get("/stations")
def get_stations():

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT *
            FROM stations
            ORDER BY station_id
            """
        )

        stations = cursor.fetchall()

        return stations

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()

# ============================================================
# BEE STATION BOOKING INFO
# ============================================================

@app.get("/stations/bee/{bee_id}/booking")
def get_bee_booking_station(bee_id: int):
    """Return booking information for ANY real BEE station.

    If the BEE station is not yet mapped into SmartCharge, this endpoint
    automatically creates the internal station, creates charger slots from
    the BEE connector_count, and stores the BEE -> SmartCharge mapping.
    """
    conn = None
    cursor = None

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # ----------------------------------------------------
        # 1. GET THE REAL BEE MASTER RECORD
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                bee_id,
                cpo_name,
                ownership,
                state,
                district,
                city_village,
                location,
                latitude,
                longitude,
                charger_type,
                charger_rating,
                connector_rating,
                connector_count
            FROM bee_ev_stations
            WHERE bee_id = %s
            LIMIT 1
            """,
            (bee_id,)
        )

        bee = cursor.fetchone()

        if not bee:
            raise HTTPException(
                status_code=404,
                detail=f"BEE station {bee_id} not found"
            )

        # ----------------------------------------------------
        # 2. CHECK WHETHER THIS BEE STATION IS ALREADY MAPPED
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                m.mapping_id,
                m.bee_id,
                m.station_id,
                s.name AS station_name,
                s.operator_name,
                s.address,
                s.status AS station_status
            FROM bee_station_mapping m
            JOIN stations s
                ON s.station_id = m.station_id
            WHERE m.bee_id = %s
            LIMIT 1
            """,
            (bee_id,)
        )

        mapped = cursor.fetchone()
        mapping_created_now = False

        # ----------------------------------------------------
        # 3. EXISTING MAPPING -> USE IT
        # ----------------------------------------------------
        if mapped:
            station_id = mapped["station_id"]
            station_name = mapped["station_name"]
            station_status = mapped["station_status"]

        # ----------------------------------------------------
        # 4. NO MAPPING -> AUTOMATICALLY CREATE ONE
        # ----------------------------------------------------
        else:
            cpo = str(bee.get("cpo_name") or "EV Charging Station").strip()
            city = str(bee.get("city_village") or "").strip()
            location = str(bee.get("location") or "").strip()

            if city:
                station_name = f"{cpo} - {city}"
            else:
                station_name = cpo

            # Convert BEE charger rating to a numeric power value.
            # Examples supported: 60, 60.0, "60 kW", "60KW".
            try:
                rating_text = str(bee.get("charger_rating") or "").strip()
                import re
                match = re.search(r"(\d+(?:\.\d+)?)", rating_text)
                power_kw = float(match.group(1)) if match else 22.0
                if power_kw <= 0:
                    power_kw = 22.0
            except Exception:
                power_kw = 22.0

            # Connector count comes directly from the BEE record.
            try:
                connector_count = int(float(bee.get("connector_count") or 0))
            except Exception:
                connector_count = 0

            # Keep at least one SmartCharge booking slot if the BEE record
            # has a missing/zero connector count.
            connector_count = max(1, connector_count)

            address = location
            if not address:
                address_parts = []
                if city:
                    address_parts.append(city)
                if bee.get("district"):
                    address_parts.append(str(bee["district"]))
                if bee.get("state"):
                    address_parts.append(str(bee["state"]))
                address = ", ".join(address_parts)

            connector_type = str(
                bee.get("charger_type") or "Unknown"
            ).strip()

            # ------------------------------------------------
            # CREATE INTERNAL SMARTCHARGE STATION
            # ------------------------------------------------
            cursor.execute(
                """
                INSERT INTO stations
                (
                    name,
                    operator_name,
                    address,
                    latitude,
                    longitude,
                    connector_type,
                    power_kw,
                    charger_count,
                    status
                )
                VALUES
                (%s, %s, %s, %s, %s, %s, %s, %s, 'active')
                """,
                (
                    station_name,
                    cpo,
                    address,
                    bee.get("latitude"),
                    bee.get("longitude"),
                    connector_type,
                    power_kw,
                    connector_count
                )
            )

            station_id = cursor.lastrowid
            station_status = "active"

            # ------------------------------------------------
            # CREATE INTERNAL CHARGER SLOTS
            # ------------------------------------------------
            for _ in range(connector_count):
                cursor.execute(
                    """
                    INSERT INTO chargers
                    (
                        station_id,
                        charger_type,
                        power_kw,
                        status
                    )
                    VALUES
                    (%s, %s, %s, 'available')
                    """,
                    (
                        station_id,
                        connector_type,
                        power_kw
                    )
                )

            # ------------------------------------------------
            # CREATE BEE -> SMARTCHARGE MAPPING
            # ------------------------------------------------
            cursor.execute(
                """
                INSERT INTO bee_station_mapping
                (
                    bee_id,
                    station_id
                )
                VALUES
                (%s, %s)
                """,
                (bee_id, station_id)
            )

            conn.commit()
            mapping_created_now = True

        # ----------------------------------------------------
        # 5. GET THE SMARTCHARGE CHARGERS
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                charger_id,
                station_id,
                charger_type,
                power_kw,
                status
            FROM chargers
            WHERE station_id = %s
            ORDER BY charger_id
            """,
            (station_id,)
        )

        chargers = cursor.fetchall()

        # ----------------------------------------------------
        # 6. RETURN REAL BEE MASTER DATA + SMARTCHARGE DATA
        # ----------------------------------------------------
        return {
            "bee_id": bee["bee_id"],
            "station_id": station_id,
            "mapping_created_now": mapping_created_now,
            "booking_source": "SmartCharge app-managed",
            "station_name": station_name,
            "operator_name": bee["cpo_name"],
            "ownership": bee["ownership"],
            "address": bee["location"],
            "state": bee["state"],
            "district": bee["district"],
            "city_village": bee["city_village"],
            "location": bee["location"],
            "latitude": float(bee["latitude"]) if bee["latitude"] is not None else None,
            "longitude": float(bee["longitude"]) if bee["longitude"] is not None else None,
            "bee_charger_type": bee["charger_type"],
            "bee_charger_rating": bee["charger_rating"],
            "connector_rating": bee["connector_rating"],
            "connector_count": bee["connector_count"],
            "station_status": station_status,
            "chargers": chargers
        }

    except HTTPException:
        if conn:
            conn.rollback()
        raise

    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Booking station preparation failed: {str(e)}"
        )

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# BEE NEARBY STATIONS
# ============================================================

@app.get("/stations/nearby")
def nearby_stations(
    latitude: float,
    longitude: float,
    radius_km: float = Query(
        default=20,
        ge=1,
        le=200
    )
):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                bee_id,
                cpo_name,
                ownership,
                state,
                district,
                city_village,
                location,
                latitude,
                longitude,
                charger_type,
                charger_rating,
                connector_rating,
                connector_count
            FROM bee_ev_stations
            WHERE latitude IS NOT NULL
              AND longitude IS NOT NULL
            """
        )

        rows = cursor.fetchall()

        result = []

        # ----------------------------------------------------
        # HAVERSINE DISTANCE
        # ----------------------------------------------------

        for station in rows:

            try:

                station_lat = float(
                    station["latitude"]
                )

                station_lng = float(
                    station["longitude"]
                )

            except Exception:

                continue

            lat1 = math.radians(latitude)
            lon1 = math.radians(longitude)

            lat2 = math.radians(station_lat)
            lon2 = math.radians(station_lng)

            dlat = lat2 - lat1
            dlon = lon2 - lon1

            a = (
                math.sin(dlat / 2) ** 2
                +
                math.cos(lat1)
                *
                math.cos(lat2)
                *
                math.sin(dlon / 2) ** 2
            )

            c = 2 * math.atan2(
                math.sqrt(a),
                math.sqrt(1 - a)
            )

            distance_km = 6371 * c

            if distance_km <= radius_km:

                station["latitude"] = station_lat
                station["longitude"] = station_lng

                station["distance_km"] = round(
                    distance_km,
                    2
                )

                result.append(station)

        # ----------------------------------------------------
        # NEAREST FIRST
        # ----------------------------------------------------

        result.sort(
            key=lambda x: x["distance_km"]
        )

        return {
            "source": "BEE EV Charging Station Dataset",
            "user_location": {
                "latitude": latitude,
                "longitude": longitude
            },
            "radius_km": radius_km,
            "count": len(result),
            "stations": result
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Nearby station search failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()



# ============================================================
# QUEUE / WAIT-TIME HELPERS
# ============================================================

def _charger_power_kw(charger_rating):
    """Extract numeric kW from charger rating text."""
    import re
    match = re.search(r"(\d+(?:\.\d+)?)", str(charger_rating or "22"))
    if not match:
        return 22.0
    try:
        value = float(match.group(1))
        return value if value > 0 else 22.0
    except Exception:
        return 22.0


def _estimate_request_minutes(
    battery_now,
    battery_required,
    battery_capacity,
    charger_rating
):
    """Approximate charging duration for queue-time estimation."""
    try:
        capacity = float(battery_capacity or 0)
        if capacity <= 0:
            return 30

        energy_kwh = (
            capacity *
            max(0.0, float(battery_required) - float(battery_now))
            / 100.0
        )

        power_kw = _charger_power_kw(charger_rating)
        minutes = (energy_kwh / power_kw) * 60.0 * 1.10
        return max(1, math.ceil(minutes))

    except Exception:
        return 30


def _get_queue_estimate(cursor, station_id, request_id):
    """
    Estimate waiting time for a waiting request.
    Uses active charging work + requests ahead in the queue,
    distributed across the station's chargers.
    """

    cursor.execute(
        """
        SELECT COUNT(*) AS total_chargers
        FROM chargers
        WHERE station_id = %s
        """,
        (station_id,)
    )

    charger_row = cursor.fetchone() or {}
    total_chargers = max(
        1,
        int(charger_row.get("total_chargers") or 1)
    )

    # Currently allocated/charging requests
    cursor.execute(
        """
        SELECT
            cr.request_id,
            cr.battery_now,
            cr.battery_required,
            v.battery_capacity,
            ch.charger_rating,
            cs.start_time
        FROM charging_requests cr
        JOIN charging_sessions cs
          ON cr.request_id = cs.request_id
        JOIN chargers ch
          ON cs.charger_id = ch.charger_id
          
        LEFT JOIN vehicles v
          ON cr.vehicle_id = v.vehicle_id
        WHERE cr.station_id = %s
          AND cr.status IN ('allocated', 'charging')
        """,
        (station_id,)
    )

    active_rows = cursor.fetchall()

    active_work = 0

    for row in active_rows:
        minutes = _estimate_request_minutes(
            row["battery_now"],
            row["battery_required"],
            row["battery_capacity"],
            row["charger_rating"]
        )

        # Reduce estimate by elapsed charging time.
        try:
            if row.get("start_time"):
                start_time = row["start_time"]

                if start_time.tzinfo is None:
                    elapsed = (
                        datetime.now() - start_time
                    ).total_seconds() / 60
                else:
                    elapsed = (
                        datetime.now(start_time.tzinfo) - start_time
                    ).total_seconds() / 60

                minutes = max(
                    1,
                    math.ceil(minutes - max(0, elapsed))
                )
        except Exception:
            pass

        active_work += minutes

    # Waiting requests ahead of this request
    cursor.execute(
        """
        SELECT
            cr.request_id,
            cr.battery_now,
            cr.battery_required,
            v.battery_capacity
        FROM charging_requests cr
        LEFT JOIN vehicles v
          ON cr.vehicle_id = v.vehicle_id
        WHERE cr.station_id = %s
          AND cr.status = 'waiting'
          AND cr.request_id < %s
        ORDER BY cr.request_id
        """,
        (station_id, request_id)
    )

    waiting_rows = cursor.fetchall()

    # Use first station charger rating as the default estimate
    cursor.execute(
        """
        SELECT charger_rating
        FROM chargers
        WHERE station_id = %s
        ORDER BY charger_id
        LIMIT 1
        """,
        (station_id,)
    )

    sample_charger = cursor.fetchone()
    sample_rating = (
        sample_charger["charger_rating"]
        if sample_charger
        else "22 kW"
    )

    waiting_work = sum(
        _estimate_request_minutes(
            row["battery_now"],
            row["battery_required"],
            row["battery_capacity"],
            sample_rating
        )
        for row in waiting_rows
    )

    total_work = active_work + waiting_work

    estimated_wait = math.ceil(
        total_work / total_chargers
    )

    return {
        "queue_position": len(waiting_rows) + 1,
        "estimated_wait_minutes": max(0, estimated_wait)
    }


# ============================================================
# CHARGING REQUEST
# ============================================================

@app.post("/charging/request")
def create_charging_request(
    request: ChargingRequest
):

    conn = None
    cursor = None

    try:

        # ----------------------------------------------------
        # VALIDATE BATTERY
        # ----------------------------------------------------

        if request.battery_now < 0 or request.battery_now > 100:

            raise HTTPException(
                status_code=400,
                detail="Current battery must be between 0 and 100"
            )

        if request.battery_required < 0 or request.battery_required > 100:

            raise HTTPException(
                status_code=400,
                detail="Required battery must be between 0 and 100"
            )

        if request.battery_required <= request.battery_now:

            raise HTTPException(
                status_code=400,
                detail="Required battery must be greater than current battery"
            )

        if request.departure_time <= request.arrival_time:

            raise HTTPException(
                status_code=400,
                detail="Departure time must be after arrival time"
            )

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # ----------------------------------------------------
        # USER CHECK
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT user_id
            FROM users
            WHERE user_id = %s
            """,
            (request.user_id,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        # ----------------------------------------------------
        # ONE ACTIVE REQUEST PER USER
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                request_id,
                station_id,
                status
            FROM charging_requests
            WHERE user_id = %s
              AND status IN ('waiting', 'allocated', 'charging')
            ORDER BY request_id DESC
            LIMIT 1
            """,
            (request.user_id,)
        )

        active_request = cursor.fetchone()

        if active_request:
            raise HTTPException(
                status_code=409,
                detail={
                    "message": (
                        "You already have an active charging request. "
                        "Complete or cancel it before creating another request."
                    ),
                    "request_id": active_request["request_id"],
                    "station_id": active_request["station_id"],
                    "status": active_request["status"]
                }
            )

        # ----------------------------------------------------
        # VEHICLE CHECK
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT vehicle_id
            FROM vehicles
            WHERE vehicle_id = %s
              AND user_id = %s
            """,
            (
                request.vehicle_id,
                request.user_id
            )
        )

        vehicle = cursor.fetchone()

        if not vehicle:

            raise HTTPException(
                status_code=404,
                detail="Vehicle not found for this user"
            )

        # ----------------------------------------------------
        # STATION CHECK
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT *
            FROM stations
            WHERE station_id = %s
            """,
            (request.station_id,)
        )

        station = cursor.fetchone()

        if not station:

            raise HTTPException(
                status_code=404,
                detail="Station not found"
            )

        # ----------------------------------------------------
        # FIND AVAILABLE CHARGER
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT *
            FROM chargers
            WHERE station_id = %s
              AND status = 'available'
            ORDER BY charger_id
            LIMIT 1
            FOR UPDATE
            """,
            (request.station_id,)
        )

        charger = cursor.fetchone()

        # ----------------------------------------------------
        # CHARGER AVAILABLE
        # ----------------------------------------------------

        if charger:

            charger_id = charger["charger_id"]

            cursor.execute(
                """
                INSERT INTO charging_requests
                (
                    user_id,
                    vehicle_id,
                    station_id,
                    battery_now,
                    battery_required,
                    arrival_time,
                    departure_time,
                    status
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    'allocated'
                )
                """,
                (
                    request.user_id,
                    request.vehicle_id,
                    request.station_id,
                    request.battery_now,
                    request.battery_required,
                    request.arrival_time,
                    request.departure_time
                )
            )

            request_id = cursor.lastrowid

            cursor.execute(
                """
                UPDATE chargers
                SET status = 'occupied'
                WHERE charger_id = %s
                """,
                (charger_id,)
            )

            # ------------------------------------------------
            # CREATE SESSION
            # ------------------------------------------------

            cursor.execute(
                """
                INSERT INTO charging_sessions
                (
                    request_id,
                    charger_id,
                    start_time,
                    status
                )
                VALUES
                (
                    %s,
                    %s,
                    NOW(),
                    'charging'
                )
                """,
                (
                    request_id,
                    charger_id
                )
            )

            session_id = cursor.lastrowid

            conn.commit()

            return {
                "message": "Charging request allocated",
                "request_id": request_id,
                "charger_id": charger_id,
                "session_id": session_id,
                "status": "allocated"
            }

        # ====================================================
        # NO AVAILABLE CHARGER
        # ====================================================

        cursor.execute(
            """
            INSERT INTO charging_requests
            (
                user_id,
                vehicle_id,
                station_id,
                battery_now,
                battery_required,
                arrival_time,
                departure_time,
                status
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                'waiting'
            )
            """,
            (
                request.user_id,
                request.vehicle_id,
                request.station_id,
                request.battery_now,
                request.battery_required,
                request.arrival_time,
                request.departure_time
            )
        )

        request_id = cursor.lastrowid

        # Queue position

        cursor.execute(
            """
            SELECT COUNT(*) AS queue_count
            FROM charging_requests
            WHERE station_id = %s
              AND status = 'waiting'
              AND request_id <= %s
            """,
            (
                request.station_id,
                request_id
            )
        )

        queue_result = cursor.fetchone()

        queue_position = (
            queue_result["queue_count"]
            if queue_result
            else 1
        )

        estimate = _get_queue_estimate(
            cursor,
            request.station_id,
            request_id
        )

        estimated_wait = max(
            queue_position - 1,
            estimate["estimated_wait_minutes"]
        )

        estimated_start = (
            datetime.now() +
            timedelta(minutes=estimated_wait)
        )

        conn.commit()

        return {
            "message": "All chargers are occupied. Request added to queue",
            "request_id": request_id,
            "status": "waiting",
            "queue_position": queue_position,
            "estimated_wait_minutes": estimated_wait,
            "estimated_start_time": estimated_start.isoformat(),
            "can_cancel_and_choose_another_station": True
        }

    except HTTPException:

        if conn:
            conn.rollback()

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=f"Charging request failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# GET REQUEST
# ============================================================

@app.get("/charging/request/{request_id}")
def get_charging_request(request_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT *
            FROM charging_requests
            WHERE request_id = %s
            """,
            (request_id,)
        )

        request = cursor.fetchone()

        if not request:

            raise HTTPException(
                status_code=404,
                detail="Charging request not found"
            )

        return request

    except HTTPException:

        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# CURRENT CHARGING
# ============================================================

@app.get("/charging/current/{user_id}")
def current_charging(user_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                cr.*,
                cs.session_id,
                cs.charger_id,
                cs.start_time,
                cs.end_time
            FROM charging_requests cr
            LEFT JOIN charging_sessions cs
                ON cr.request_id = cs.request_id
            WHERE cr.user_id = %s
              AND cr.status IN
              (
                  'allocated',
                  'charging',
                  'waiting'
              )
            ORDER BY cr.request_id DESC
            LIMIT 1
            """,
            (user_id,)
        )

        result = cursor.fetchone()

        if not result:

            return {
                "active": False,
                "message": "No active charging request"
            }

        if result.get("status") == "waiting":
            estimate = _get_queue_estimate(
                cursor,
                result["station_id"],
                result["request_id"]
            )

            wait_minutes = estimate["estimated_wait_minutes"]

            result["queue_position"] = estimate["queue_position"]
            result["estimated_wait_minutes"] = wait_minutes
            result["estimated_start_time"] = (
                datetime.now() +
                timedelta(minutes=wait_minutes)
            ).isoformat()
            result["can_cancel_and_choose_another_station"] = True
        else:
            result["can_cancel_and_choose_another_station"] = False

        return {
            "active": True,
            "charging": result
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Current charging failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# CHARGING HISTORY
# ============================================================

@app.get("/charging/history/{user_id}")
def charging_history(user_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                cr.*,
                cs.session_id,
                cs.charger_id,
                cs.start_time,
                cs.end_time
            FROM charging_requests cr
            LEFT JOIN charging_sessions cs
                ON cr.request_id = cs.request_id
            WHERE cr.user_id = %s
            ORDER BY cr.request_id DESC
            """,
            (user_id,)
        )

        history = cursor.fetchall()

        return history

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"History failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# QUEUE BY STATION
# ============================================================

@app.get("/queue/{station_id}")
def get_station_queue(station_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                request_id,
                user_id,
                vehicle_id,
                station_id,
                battery_now,
                battery_required,
                arrival_time,
                departure_time,
                status
            FROM charging_requests
            WHERE station_id = %s
              AND status = 'waiting'
            ORDER BY request_id
            """,
            (station_id,)
        )

        queue = cursor.fetchall()

        # Add position

        for index, item in enumerate(
            queue,
            start=1
        ):

            item["queue_position"] = index

        return queue

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# USER QUEUE
# ============================================================

@app.get("/queue/user/{user_id}")
def get_user_queue(user_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                request_id,
                user_id,
                vehicle_id,
                station_id,
                battery_now,
                battery_required,
                arrival_time,
                departure_time,
                status
            FROM charging_requests
            WHERE user_id = %s
              AND status = 'waiting'
            ORDER BY request_id
            """,
            (user_id,)
        )

        queue = cursor.fetchall()

        for item in queue:
            estimate = _get_queue_estimate(
                cursor,
                item["station_id"],
                item["request_id"]
            )

            wait_minutes = estimate["estimated_wait_minutes"]

            item["queue_position"] = estimate["queue_position"]
            item["estimated_wait_minutes"] = wait_minutes
            item["estimated_start_time"] = (
                datetime.now() +
                timedelta(minutes=wait_minutes)
            ).isoformat()
            item["can_cancel_and_choose_another_station"] = True

        return queue

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# COMPLETE CHARGING
# ============================================================

@app.post("/charging/complete/{session_id}")
def complete_charging(session_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET SESSION
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT *
            FROM charging_sessions
            WHERE session_id = %s
            """,
            (session_id,)
        )

        session = cursor.fetchone()

        if not session:

            raise HTTPException(
                status_code=404,
                detail="Charging session not found"
            )

        request_id = session["request_id"]
        charger_id = session["charger_id"]

        # ----------------------------------------------------
        # COMPLETE SESSION
        # ----------------------------------------------------

        cursor.execute(
            """
            UPDATE charging_sessions
            SET
                end_time = NOW(),
                status = 'completed'
            WHERE session_id = %s
            """,
            (session_id,)
        )

        # ----------------------------------------------------
        # COMPLETE REQUEST
        # ----------------------------------------------------

        cursor.execute(
            """
            UPDATE charging_requests
            SET status = 'completed'
            WHERE request_id = %s
            """,
            (request_id,)
        )

        # ----------------------------------------------------
        # FREE CHARGER
        # ----------------------------------------------------

        cursor.execute(
            """
            UPDATE chargers
            SET status = 'available'
            WHERE charger_id = %s
            """,
            (charger_id,)
        )

        # ----------------------------------------------------
        # FIND NEXT WAITING REQUEST
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT *
            FROM charging_requests
            WHERE station_id =
            (
                SELECT station_id
                FROM charging_requests
                WHERE request_id = %s
            )
            AND status = 'waiting'
            ORDER BY request_id
            LIMIT 1
            FOR UPDATE
            """,
            (request_id,)
        )

        next_request = cursor.fetchone()

        if next_request:

            next_request_id = next_request[
                "request_id"
            ]

            # Allocate

            cursor.execute(
                """
                UPDATE charging_requests
                SET status = 'allocated'
                WHERE request_id = %s
                """,
                (next_request_id,)
            )

            cursor.execute(
                """
                UPDATE chargers
                SET status = 'occupied'
                WHERE charger_id = %s
                """,
                (charger_id,)
            )

            cursor.execute(
                """
                INSERT INTO charging_sessions
                (
                    request_id,
                    charger_id,
                    start_time,
                    status
                )
                VALUES
                (
                    %s,
                    %s,
                    NOW(),
                    'charging'
                )
                """,
                (
                    next_request_id,
                    charger_id
                )
            )

            conn.commit()

            return {
                "message":
                    "Charging completed and next queued EV allocated",
                "completed_request_id":
                    request_id,
                "charger_id":
                    charger_id,
                "next_request_id":
                    next_request_id,
                "status":
                    "allocated"
            }

        conn.commit()

        return {
            "message":
                "Charging completed",
            "completed_request_id":
                request_id,
            "charger_id":
                charger_id,
            "next_request_id":
                None,
            "status":
                "completed"
        }

    except HTTPException:

        if conn:
            conn.rollback()

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=f"Charging completion failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# CANCEL REQUEST
# ============================================================

@app.post("/charging/cancel/{request_id}")
def cancel_charging(request_id: int):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET REQUEST
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT *
            FROM charging_requests
            WHERE request_id = %s
            """,
            (request_id,)
        )

        request = cursor.fetchone()

        if not request:

            raise HTTPException(
                status_code=404,
                detail="Charging request not found"
            )

        current_status = request["status"]

        # ----------------------------------------------------
        # WAITING
        # ----------------------------------------------------

        if current_status == "waiting":

            cursor.execute(
                """
                UPDATE charging_requests
                SET status = 'cancelled'
                WHERE request_id = %s
                """,
                (request_id,)
            )

            conn.commit()

            return {
                "message":
                    "Waiting request cancelled",
                "request_id":
                    request_id,
                "status":
                    "cancelled"
            }

        # ----------------------------------------------------
        # ALLOCATED / CHARGING
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT *
            FROM charging_sessions
            WHERE request_id = %s
            ORDER BY session_id DESC
            LIMIT 1
            """,
            (request_id,)
        )

        session = cursor.fetchone()

        if session:

            charger_id = session["charger_id"]

            cursor.execute(
                """
                UPDATE charging_sessions
                SET
                    end_time = NOW(),
                    status = 'cancelled'
                WHERE session_id = %s
                """,
                (session["session_id"],)
            )

            cursor.execute(
                """
                UPDATE chargers
                SET status = 'available'
                WHERE charger_id = %s
                """,
                (charger_id,)
            )

        cursor.execute(
            """
            UPDATE charging_requests
            SET status = 'cancelled'
            WHERE request_id = %s
            """,
            (request_id,)
        )

        conn.commit()

        return {
            "message":
                "Charging request cancelled",
            "request_id":
                request_id,
            "status":
                "cancelled"
        }

    except HTTPException:

        if conn:
            conn.rollback()

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=f"Cancellation failed: {str(e)}"
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# SERVER START
# ============================================================

if __name__ == "__main__":

    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg
from datetime import datetime, timezone
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Configuration de la clé secrète (pour les sessions, etc.)
app.secret_key = os.getenv("SECRET_KEY", os.urandom(32).hex())

# Configuration CORS pour la production
cors_origins = os.getenv("CORS_ORIGINS", "*")
if cors_origins != "*":
    # Si des origines spécifiques sont configurées, les utiliser
    allowed_origins = [origin.strip() for origin in cors_origins.split(",")]
    CORS(app, origins=allowed_origins)
else:
    # En développement, autoriser toutes les origines
    CORS(app)

# 🔧 Configuration
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "dbname": os.getenv("DB_NAME", "Traffic_Tracking"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "postgres"),
    "port": int(os.getenv("DB_PORT", "5433")),
    "client_encoding": "UTF8",
}

def get_connection():
    try:
        return psycopg.connect(**DB_CONFIG)
    except Exception as e:
        app.logger.error(f"Database connection error: {str(e)}")
        raise

@app.route('/')
def home():
    return jsonify({"message": "Traffic Tracking API"})

@app.route('/health')
def health():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        cur.fetchone()
        cur.close()
        conn.close()
        return jsonify({"status": "healthy"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "details": str(e)}), 500

# Endpoint to create table if missing (use once)
@app.route('/init_db', methods=['POST'])
def init_db():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS gps_points (
                id SERIAL PRIMARY KEY,
                driver_id TEXT,
                phone_number TEXT,
                latitude DOUBLE PRECISION NOT NULL,
                longitude DOUBLE PRECISION NOT NULL,
                speed DOUBLE PRECISION,
                timestamp TIMESTAMP NOT NULL
            );
        """)
        # Ajouter la colonne phone_number si elle n'existe pas déjà (pour les installations existantes)
        cur.execute("""
            DO $$ 
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM information_schema.columns 
                    WHERE table_name='gps_points' AND column_name='phone_number'
                ) THEN
                    ALTER TABLE gps_points ADD COLUMN phone_number TEXT;
                END IF;
            END $$;
        """)
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"status": "ok", "message": "table ensured"}), 200
    except Exception as e:
        app.logger.exception("init_db failed")
        return jsonify({"error": "init_db failed", "details": str(e)}), 500

@app.route("/send_gps", methods=["POST"])
def send_gps():
    try:
        data = request.get_json(force=True, silent=False)
        driver_id = data.get("driver_id", "anon")
        phone_number = data.get("phone_number")
        lat = data.get("latitude")
        lon = data.get("longitude")
        speed = data.get("speed", 0.0)

        if lat is None or lon is None:
            return jsonify({"error": "missing coordinates"}), 400

        # Validation du numéro de téléphone (10 chiffres)
        if phone_number:
            # Nettoyer le numéro (enlever espaces, tirets, etc.)
            phone_clean = ''.join(filter(str.isdigit, str(phone_number)))
            if len(phone_clean) != 10:
                return jsonify({"error": "phone_number must be exactly 10 digits"}), 400
            phone_number = phone_clean

        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO gps_points (driver_id, phone_number, latitude, longitude, speed, timestamp)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (driver_id, phone_number, float(lat), float(lon), float(speed), datetime.now(timezone.utc)))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"status": "ok"}), 201
    except Exception as e:
        app.logger.exception("send_gps failed")
        # Retourner message utile pour debug, attention en prod
        return jsonify({"error": "insert failed", "details": str(e)}), 500

@app.route("/get_points", methods=["GET"])
def get_points():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, driver_id, phone_number, latitude, longitude, speed, timestamp FROM gps_points ORDER BY id DESC LIMIT 100;")
        rows = cur.fetchall()
        cur.close()
        conn.close()

        return jsonify([
            {
                "id": r[0],
                "driver_id": r[1],
                "phone_number": r[2],
                "latitude": r[3],
                "longitude": r[4],
                "speed": r[5],
                "timestamp": r[6].isoformat() if r[6] else None
            }
            for r in rows
        ]), 200
    except Exception as e:
        app.logger.exception("get_points failed")
        return jsonify({"error": "query failed", "details": str(e)}), 500

if __name__ == "__main__":
    # Development mode - use Flask development server
    port = int(os.getenv("FLASK_PORT", "5000"))
    debug = os.getenv("FLASK_DEBUG", "true").lower() == "true"
    
    if debug:
        app.logger.warning("⚠️  Running in DEBUG mode - not suitable for production!")
        app.logger.warning("⚠️  Use 'start_backend_production.ps1' for production deployment")
    
    app.run(debug=debug, host="0.0.0.0", port=port)

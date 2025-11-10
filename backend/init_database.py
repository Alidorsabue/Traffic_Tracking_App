import psycopg
import sys
import os
from dotenv import load_dotenv

# Set console encoding to UTF-8
sys.stdout.reconfigure(encoding='utf-8')

def init_database():
    load_dotenv()

    connection_params = {
        "host": os.getenv("DB_HOST", "localhost"),
        "dbname": os.getenv("DB_MAINTENANCE_DB", "postgres"),
        "user": os.getenv("DB_USER", "postgres"),
        "password": os.getenv("DB_PASSWORD", "postgres"),
        "port": int(os.getenv("DB_PORT", "5432")),
    }
    
    try:
        # Connect to default database
        conn = psycopg.connect(**connection_params)
        conn.set_client_encoding('UTF8')
        conn.autocommit = True
        cur = conn.cursor()
        
        # Terminate existing connections
        cur.execute("""
            SELECT pg_terminate_backend(pg_stat_activity.pid)
            FROM pg_stat_activity
            WHERE pg_stat_activity.datname = 'Traffic_Tracking'
            AND pid <> pg_backend_pid();
        """)
        
        # Drop and recreate database
        cur.execute('DROP DATABASE IF EXISTS "Traffic_Tracking"')
        cur.execute("""
            CREATE DATABASE "Traffic_Tracking"
            WITH ENCODING = 'UTF8'
            LC_COLLATE = 'English_United States.1252'
            LC_CTYPE = 'English_United States.1252'
            TEMPLATE template0;
        """)
        
        print("Database created successfully with UTF8 encoding")
        return True
        
    except Exception as e:
        print(f"Database initialization error: {str(e)}")
        return False
        
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    init_database()
    
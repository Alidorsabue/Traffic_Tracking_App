"""
Script pour creer la table gps_points dans la base de donnees Traffic_Tracking
Usage: python create_table.py
"""
import psycopg
import os
import sys
from dotenv import load_dotenv

# Fixer l'encodage pour Windows
sys.stdout.reconfigure(encoding='utf-8')

load_dotenv()

def create_table():
    """Crée la table gps_points si elle n'existe pas"""
    connection_params = {
        "host": os.getenv("DB_HOST", "localhost"),
        "dbname": os.getenv("DB_NAME", "Traffic_Tracking"),
        "user": os.getenv("DB_USER", "postgres"),
        "password": os.getenv("DB_PASSWORD", "postgres"),
        "port": int(os.getenv("DB_PORT", "5433")),
    }
    
    try:
        print("Connexion a la base de donnees...")
        print(f"Host: {connection_params['host']}, Port: {connection_params['port']}, Database: {connection_params['dbname']}")
        conn = psycopg.connect(**connection_params)
        conn.set_client_encoding('UTF8')
        cur = conn.cursor()
        
        # Vérifier si la table existe déjà
        cur.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'gps_points'
            );
        """)
        table_exists = cur.fetchone()[0]
        
        if table_exists:
            print("[WARNING] La table 'gps_points' existe deja.")
            response = input("Voulez-vous la recreer ? (oui/non): ")
            if response.lower() in ['oui', 'o', 'yes', 'y']:
                cur.execute("DROP TABLE IF EXISTS gps_points CASCADE;")
                conn.commit()
                print("[OK] Table supprimee.")
            else:
                print("[CANCEL] Operation annulee.")
                cur.close()
                conn.close()
                return
        
        # Creer la table
        print("Creation de la table 'gps_points'...")
        cur.execute("""
            CREATE TABLE gps_points (
                id SERIAL PRIMARY KEY,
                driver_id TEXT,
                latitude DOUBLE PRECISION NOT NULL,
                longitude DOUBLE PRECISION NOT NULL,
                speed DOUBLE PRECISION,
                timestamp TIMESTAMP NOT NULL
            );
        """)
        
        conn.commit()
        print("[OK] Table 'gps_points' creee avec succes !")
        
        # Afficher la structure de la table
        cur.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'gps_points'
            ORDER BY ordinal_position;
        """)
        
        columns = cur.fetchall()
        print("\n[INFO] Structure de la table:")
        print("-" * 60)
        print(f"{'Colonne':<20} {'Type':<25} {'Nullable':<10}")
        print("-" * 60)
        for col in columns:
            print(f"{col[0]:<20} {col[1]:<25} {col[2]:<10}")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"[ERREUR] Erreur lors de la creation de la table: {str(e)}")
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    create_table()


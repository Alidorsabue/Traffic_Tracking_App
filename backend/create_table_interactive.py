"""
Script interactif pour creer la table gps_points
Demande le mot de passe PostgreSQL de maniere securisee
Usage: python create_table_interactive.py
"""
import psycopg
import os
import sys
import getpass

# Fixer l'encodage pour Windows
sys.stdout.reconfigure(encoding='utf-8')

def create_table_interactive():
    """Cree la table gps_points en demandant les credentials"""
    
    print("=" * 60)
    print("Creation de la table gps_points")
    print("=" * 60)
    print()
    
    # Demander les informations de connexion
    host = input("Host PostgreSQL [localhost]: ").strip() or "localhost"
    port = input("Port PostgreSQL [5433]: ").strip() or "5433"
    dbname = input("Nom de la base de donnees [Traffic_Tracking]: ").strip() or "Traffic_Tracking"
    user = input("Utilisateur PostgreSQL [postgres]: ").strip() or "postgres"
    password = getpass.getpass("Mot de passe PostgreSQL: ")
    
    connection_params = {
        "host": host,
        "dbname": dbname,
        "user": user,
        "password": password,
        "port": int(port),
    }
    
    try:
        print("\nConnexion a la base de donnees...")
        conn = psycopg.connect(**connection_params)
        conn.set_client_encoding('UTF8')
        cur = conn.cursor()
        
        # Verifier si la table existe deja
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
        print("\n[SUCCESS] Table creee et verifiee avec succes !")
        
    except psycopg.OperationalError as e:
        print(f"\n[ERREUR] Erreur de connexion: {str(e)}")
        print("\nVeuillez verifier:")
        print("- Que PostgreSQL est demarre")
        print("- Que le host, port, utilisateur et mot de passe sont corrects")
    except Exception as e:
        print(f"\n[ERREUR] Erreur lors de la creation de la table: {str(e)}")
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    create_table_interactive()















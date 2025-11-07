"""
Script pour tester la connexion au backend et vérifier que la table existe
Usage: python test_connection.py
"""
import requests
import sys

def test_backend():
    """Teste la connexion au backend Flask"""
    
    base_url = "http://localhost:5000"
    
    print("=" * 60)
    print("Test de connexion au backend Flask")
    print("=" * 60)
    print()
    
    # Test 1: Health check
    try:
        print(f"1. Test du endpoint /health...")
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            print(f"   [OK] Backend accessible: {response.json()}")
        else:
            print(f"   [ERREUR] Status code: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print(f"   [ERREUR] Impossible de se connecter au backend sur {base_url}")
        print(f"   Assurez-vous que le backend Flask est lance (start_backend.ps1)")
        return False
    except Exception as e:
        print(f"   [ERREUR] {str(e)}")
        return False
    
    # Test 2: Envoyer un point GPS
    try:
        print(f"\n2. Test d'envoi de point GPS...")
        test_data = {
            "latitude": -4.325,
            "longitude": 15.322,
            "speed": 0.0,
            "driver_id": "test_user"
        }
        response = requests.post(
            f"{base_url}/send_gps",
            json=test_data,
            timeout=5
        )
        if response.status_code == 201:
            print(f"   [OK] Point GPS envoye avec succes")
        else:
            print(f"   [ERREUR] Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print(f"   [ERREUR] {str(e)}")
    
    # Test 3: Récupérer les points
    try:
        print(f"\n3. Test de recuperation des points...")
        response = requests.get(f"{base_url}/get_points", timeout=5)
        if response.status_code == 200:
            points = response.json()
            print(f"   [OK] {len(points)} point(s) recupere(s)")
            if points:
                print(f"   Premier point: {points[0]}")
        else:
            print(f"   [ERREUR] Status code: {response.status_code}")
    except Exception as e:
        print(f"   [ERREUR] {str(e)}")
    
    print("\n" + "=" * 60)
    print("Tests termines")
    print("=" * 60)
    return True

if __name__ == "__main__":
    try:
        test_backend()
    except KeyboardInterrupt:
        print("\n\nTest interrompu par l'utilisateur")
        sys.exit(1)


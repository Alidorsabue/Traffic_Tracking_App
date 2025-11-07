"""
WSGI entry point for production deployment.

Ce fichier est utilisé par Waitress pour lancer l'application Flask en mode production.
Usage: waitress-serve --host=0.0.0.0 --port=5000 --call wsgi:app
"""

# Charger l'application Flask
from app import app

# Exporter l'application pour Waitress
application = app


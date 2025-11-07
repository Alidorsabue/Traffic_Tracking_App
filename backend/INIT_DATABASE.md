# Initialisation de la base de données

## Table : `gps_points`

La table `gps_points` stocke toutes les positions GPS envoyées par l'application mobile avec le numéro de téléphone de l'utilisateur.

### Structure de la table

| Colonne      | Type              | Description                                    |
|--------------|-------------------|------------------------------------------------|
| id           | SERIAL PRIMARY KEY| Identifiant unique auto-incrémenté             |
| driver_id    | TEXT              | Identifiant du conducteur (défaut: "anon")      |
| phone_number | TEXT              | Numéro de téléphone (10 chiffres, optionnel)   |
| latitude     | DOUBLE PRECISION  | Latitude GPS (obligatoire)                     |
| longitude    | DOUBLE PRECISION  | Longitude GPS (obligatoire)                    |
| speed        | DOUBLE PRECISION  | Vitesse en m/s                                  |
| timestamp    | TIMESTAMP         | Date et heure d'enregistrement (UTC)           |

### Notes importantes

- **phone_number** : Le numéro de téléphone doit contenir exactement 10 chiffres. Le backend nettoie automatiquement le format (enlève espaces, tirets, etc.) et valide la longueur.
- **timestamp** : Toutes les dates sont stockées en UTC (Coordinated Universal Time).
- **Migration automatique** : Si vous avez une base de données existante, l'endpoint `/init_db` ajoutera automatiquement la colonne `phone_number` si elle n'existe pas déjà.

## Méthodes pour créer/mettre à jour la table

### Méthode 1 : Endpoint API (RECOMMANDÉ)

Assurez-vous que le backend Flask est lancé, puis :

**Via PowerShell :**
```powershell
Invoke-WebRequest -Method POST http://localhost:5000/init_db -UseBasicParsing
```

**Via curl :**
```bash
curl -X POST http://localhost:5000/init_db
```

**Avantages :**
- ✅ Crée la table si elle n'existe pas
- ✅ Ajoute automatiquement la colonne `phone_number` si elle manque (migration)
- ✅ Idempotent : peut être exécuté plusieurs fois sans erreur

### Méthode 2 : Script Python

```powershell
cd backend
venv\Scripts\python.exe create_table.py
```

**Note :** Ce script crée la table mais ne gère pas la migration de `phone_number` pour les bases existantes. Utilisez plutôt l'endpoint `/init_db`.

### Méthode 3 : SQL direct dans pgAdmin

Connectez-vous à pgAdmin, sélectionnez la base `Traffic_Tracking`, et exécutez :

```sql
-- Créer la table si elle n'existe pas
CREATE TABLE IF NOT EXISTS gps_points (
    id SERIAL PRIMARY KEY,
    driver_id TEXT,
    phone_number TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed DOUBLE PRECISION,
    timestamp TIMESTAMP NOT NULL
);

-- Ajouter la colonne phone_number si elle n'existe pas (pour les installations existantes)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='gps_points' AND column_name='phone_number'
    ) THEN
        ALTER TABLE gps_points ADD COLUMN phone_number TEXT;
    END IF;
END $$;
```

## Migration depuis une version précédente

Si vous avez déjà une base de données avec la table `gps_points` sans le champ `phone_number`, vous pouvez :

### Option 1 : Utiliser l'endpoint `/init_db` (RECOMMANDÉ)

```powershell
Invoke-WebRequest -Method POST http://localhost:5000/init_db -UseBasicParsing
```

Cela ajoutera automatiquement la colonne `phone_number` si elle n'existe pas.

### Option 2 : Ajouter manuellement la colonne

Dans pgAdmin ou psql :

```sql
ALTER TABLE gps_points ADD COLUMN phone_number TEXT;
```

## Vérification

### Dans pgAdmin

1. Connectez-vous à pgAdmin
2. Développez : Servers > PostgreSQL > Databases > Traffic_Tracking > Schemas > public > Tables
3. Clic droit sur `gps_points` > View/Edit Data > All Rows
4. Vérifiez que la colonne `phone_number` existe

### Vérifier la structure de la table

```sql
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'gps_points'
ORDER BY ordinal_position;
```

### Via l'API

```powershell
# Tester la connexion
Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing

# Vérifier que la table est accessible
Invoke-WebRequest -Uri http://localhost:5000/get_points -UseBasicParsing
```

## Requêtes utiles

### Voir tous les points GPS récents

```sql
SELECT 
    id,
    driver_id,
    phone_number,
    latitude,
    longitude,
    speed,
    timestamp
FROM gps_points 
ORDER BY timestamp DESC 
LIMIT 100;
```

### Compter les points GPS

```sql
SELECT COUNT(*) as total_points FROM gps_points;
```

### Voir les points d'un numéro de téléphone spécifique

```sql
SELECT 
    id,
    latitude,
    longitude,
    speed,
    timestamp
FROM gps_points 
WHERE phone_number = '0123456789'
ORDER BY timestamp DESC;
```

### Voir les points d'un conducteur spécifique

```sql
SELECT 
    id,
    phone_number,
    latitude,
    longitude,
    speed,
    timestamp
FROM gps_points 
WHERE driver_id = 'driver1' 
ORDER BY timestamp DESC;
```

### Statistiques par numéro de téléphone

```sql
SELECT 
    phone_number,
    COUNT(*) as nombre_points,
    MIN(timestamp) as premier_point,
    MAX(timestamp) as dernier_point
FROM gps_points
WHERE phone_number IS NOT NULL
GROUP BY phone_number
ORDER BY nombre_points DESC;
```

### Points GPS d'aujourd'hui

```sql
SELECT 
    phone_number,
    COUNT(*) as points_aujourdhui
FROM gps_points
WHERE DATE(timestamp) = CURRENT_DATE
GROUP BY phone_number;
```

### Vider la table (ATTENTION: supprime toutes les données)

```sql
TRUNCATE TABLE gps_points;
```

### Supprimer la table (ATTENTION: supprime la table et toutes les données)

```sql
DROP TABLE IF EXISTS gps_points CASCADE;
```

### Supprimer les points d'un numéro de téléphone spécifique

```sql
DELETE FROM gps_points WHERE phone_number = '0123456789';
```

## Validation des données

### Vérifier les numéros de téléphone invalides (pas 10 chiffres)

```sql
SELECT 
    id,
    phone_number,
    LENGTH(REGEXP_REPLACE(phone_number, '[^0-9]', '', 'g')) as longueur_chiffres
FROM gps_points
WHERE phone_number IS NOT NULL
    AND LENGTH(REGEXP_REPLACE(phone_number, '[^0-9]', '', 'g')) != 10;
```

### Compter les points avec et sans numéro de téléphone

```sql
SELECT 
    CASE 
        WHEN phone_number IS NULL THEN 'Sans numéro'
        ELSE 'Avec numéro'
    END as statut,
    COUNT(*) as nombre
FROM gps_points
GROUP BY statut;
```

## Exemples de données

### Insertion manuelle (pour test)

```sql
INSERT INTO gps_points (driver_id, phone_number, latitude, longitude, speed, timestamp)
VALUES (
    'test_driver',
    '0123456789',
    -4.3250,
    15.3220,
    0.0,
    NOW()
);
```

### Exemple de données retournées par l'API

```json
[
    {
        "id": 1,
        "driver_id": "anon",
        "phone_number": "0123456789",
        "latitude": -4.3250,
        "longitude": 15.3220,
        "speed": 0.0,
        "timestamp": "2024-01-15T10:30:00Z"
    }
]
```

## Notes de sécurité

- ⚠️ Le numéro de téléphone est stocké en texte brut. Pour une application de production, considérez le chiffrement.
- ⚠️ Les numéros sont validés côté backend (10 chiffres exactement) avant insertion.
- ⚠️ Le backend nettoie automatiquement les numéros (enlève espaces, tirets, etc.).

## Dépannage

### La colonne phone_number n'apparaît pas

1. Vérifiez que vous avez exécuté `/init_db` après la mise à jour
2. Vérifiez manuellement dans pgAdmin si la colonne existe
3. Si nécessaire, ajoutez-la manuellement avec `ALTER TABLE gps_points ADD COLUMN phone_number TEXT;`

### Erreur lors de la migration

Si vous obtenez une erreur lors de l'ajout de la colonne, vérifiez qu'il n'y a pas de conflit :

```sql
-- Vérifier si la colonne existe déjà
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'gps_points' AND column_name = 'phone_number';
```

# Configuration du démarrage automatique du backend

## Méthode 1 : Planificateur de tâches Windows (RECOMMANDÉ)

### Étapes :

1. **Ouvrir le Planificateur de tâches**
   - Appuyez sur `Win + R`
   - Tapez `taskschd.msc` et appuyez sur Entrée

2. **Créer une nouvelle tâche**
   - Cliquez sur "Créer une tâche" (à droite)
   - **Onglet Général** :
     - Nom : `Traffic Tracking Backend`
     - Description : `Démarrage automatique du backend Flask`
     - Cochez "Exécuter que l'utilisateur soit connecté ou non"
     - Cochez "Exécuter avec les privilèges les plus élevés"

3. **Onglet Déclencheurs**
   - Cliquez sur "Nouveau"
   - Déclencheur : "Au démarrage"
   - Cochez "Activé"
   - Cliquez sur "OK"

4. **Onglet Actions**
   - Cliquez sur "Nouveau"
   - Action : "Démarrer un programme"
   - Programme/script : 
     ```
     C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\start_backend_background.bat
     ```
   - Cliquez sur "OK"

5. **Onglet Conditions** (Optionnel)
   - Décochez "Mettre en veille uniquement si l'ordinateur est branché sur secteur"
   - Décochez "Réveiller l'ordinateur pour exécuter cette tâche"

6. **Onglet Paramètres**
   - Cochez "Autoriser l'exécution de la tâche à la demande"
   - Cochez "Exécuter la tâche dès que possible après un démarrage manqué"
   - Si la tâche échoue, redémarrer toutes les : `5 minutes`
   - Tenter de redémarrer jusqu'à : `3 fois`

7. Cliquez sur "OK" et entrez votre mot de passe Windows si demandé

### Vérification

Après le redémarrage, vérifiez que le backend fonctionne :
```powershell
Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
```

Ou vérifiez les logs :
```powershell
Get-Content backend\backend.log -Tail 20
```

## Méthode 2 : Dossier de démarrage Windows

1. **Ouvrir le dossier de démarrage**
   - Appuyez sur `Win + R`
   - Tapez `shell:startup` et appuyez sur Entrée

2. **Créer un raccourci**
   - Clic droit > Nouveau > Raccourci
   - Chemin : 
     ```
     C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\start_backend_silent.vbs
     ```
   - Nommer le raccourci : `Traffic Tracking Backend`

3. **Propriétés du raccourci (Optionnel)**
   - Clic droit sur le raccourci > Propriétés
   - Onglet Raccourci > Exécuter : "Réduit"

**Note** : Cette méthode nécessite que l'utilisateur soit connecté. Le Planificateur de tâches est préférable.

## Méthode 3 : Service Windows (Avancé)

Pour une solution plus robuste, vous pouvez créer un service Windows avec `NSSM` (Non-Sucking Service Manager) :

1. Télécharger NSSM : https://nssm.cc/download
2. Installer le service :
   ```powershell
   nssm install TrafficTrackingBackend
   ```
3. Configurer :
   - Path : `C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\venv\Scripts\python.exe`
   - Startup directory : `C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend`
   - Arguments : `app.py`

## Dépannage

### Le backend ne démarre pas au démarrage

1. Vérifiez les logs d'erreur :
   ```powershell
   Get-Content backend\backend_error.log
   ```

2. Vérifiez que le chemin est correct (les espaces peuvent poser problème)

3. Testez manuellement le script :
   ```powershell
   cd backend
   .\start_backend_background.bat
   ```

4. Vérifiez les tâches planifiées :
   - Ouvrez le Planificateur de tâches
   - Cherchez "Traffic Tracking Backend"
   - Clic droit > Exécuter maintenant
   - Vérifiez l'historique pour voir les erreurs

### Vérifier si le backend est en cours d'exécution

```powershell
Get-Process python | Where-Object {$_.Path -like "*venv*"}
```

Ou testez directement :
```powershell
Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
```


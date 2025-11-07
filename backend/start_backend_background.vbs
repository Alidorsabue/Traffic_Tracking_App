' Script VBS pour lancer le backend en arrière-plan sans fenêtre visible
' Utilisé pour le démarrage automatique au démarrage de Windows

Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Chemin du script batch
scriptPath = "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\start_backend_background.bat"
logDir = "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\logs"

' Créer le dossier logs s'il n'existe pas
If Not fso.FolderExists(logDir) Then
    fso.CreateFolder(logDir)
End If

' Vérifier que le script existe
If Not fso.FileExists(scriptPath) Then
    ' Créer un fichier de log d'erreur
    Set logFile = fso.CreateTextFile(logDir & "\vbs_error.log", True)
    logFile.WriteLine "[" & Now & "] [ERREUR] Script non trouve: " & scriptPath
    logFile.Close
    WScript.Quit
End If

' Lancer le script en arrière-plan sans fenêtre visible
' 0 = masquer la fenêtre, False = ne pas attendre la fin
WshShell.Run "cmd.exe /c """ & scriptPath & """", 0, False

' Le script VBS se termine immédiatement, le processus batch continue en arrière-plan
Set WshShell = Nothing
Set fso = Nothing


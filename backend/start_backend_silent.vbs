Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Chemin vers le dossier backend
scriptPath = "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"
batFile = scriptPath & "\start_backend.bat"

' Vérifier que le fichier existe
If Not fso.FileExists(batFile) Then
    WScript.Echo "Erreur: Fichier non trouvé: " & batFile
    WScript.Quit
End If

' Changer le répertoire et lancer le script en arrière-plan
WshShell.CurrentDirectory = scriptPath
WshShell.Run "cmd.exe /c " & Chr(34) & batFile & Chr(34), 0, False

' Le script VBS se termine immédiatement, laissant le processus en arrière-plan

@echo off
set vaultAddress=%1
set adminPassword=%2
set serverKeyPath=%3
cd Pacli
pacli.exe init
Pacli.exe define vault=v address=%vaultAddress%
Pacli.exe default vault=v user=administrator
Pacli.exe logon vault=v user=administrator PASSWORD=%adminPassword%
Pacli.exe OPENSAFE vault=v user=administrator SAFE=System
Pacli.exe RETRIEVEPASSWORDOBJECT VAULT=v USER=administrator SAFE=System FOLDER=root FILE=VKMKeyUUID REQUESTREASON="Cloud Vendor Post installation process" output(PASSWORD) > "VKMKeyUUID.txt"
Pacli.exe DELETEFILE VAULT=v USER=administrator SAFE=System FOLDER=root FILE=VKMKeyUUID
Pacli.exe RETRIEVEFILE VAULT=v USER=administrator SAFE=System FOLDER=root FILE=Server.key  LOCALFOLDER=%serverKeyPath% LOCALFILE=Server.key
Pacli.exe DELETEFILE VAULT=v USER=administrator SAFE=System FOLDER=root FILE=Server.key
Pacli.exe CLOSESAFE  vault=v user=administrator SAFE=System
Pacli.exe LOGOFF VAULT=v USER=administrator
pacli.exe term
cd ..
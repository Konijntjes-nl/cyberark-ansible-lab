@echo off
set vaultAddress=%1
set adminPassword=%2
set VKMKeyUUID=%3
set serverKeyPath=%4
cd Pacli
pacli.exe init
Pacli.exe define vault=v address=%vaultAddress%
Pacli.exe default vault=v user=administrator
Pacli.exe logon vault=v user=administrator PASSWORD=%adminPassword%
Pacli.exe OPENSAFE vault=v user=administrator SAFE=System
Pacli.exe STOREPASSWORDOBJECT VAULT=v USER=administrator SAFE=System FOLDER=root FILE=VKMKeyUUID PASSWORD=%VKMKeyUUID%
Pacli.exe STOREFILE VAULT=v USER=administrator SAFE=System FOLDER=root FILE=Server.key LOCALFOLDER=%serverKeyPath% LOCALFILE=Server.key
Pacli.exe CLOSESAFE  vault=v user=administrator SAFE=System
Pacli.exe LOGOFF VAULT=v USER=administrator
pacli.exe term
cd ..
@echo off

reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL
%SystemRoot%\SysWOW64\cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL

powershell -File e:\init-control.ps1

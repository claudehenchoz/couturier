# $a = Read-Host -Prompt "Press Enter to continue"

# Install Chocolatey
Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install packages
choco install firefox git gitextensions sysinternals 7zip libreoffice citrix-receiver -y

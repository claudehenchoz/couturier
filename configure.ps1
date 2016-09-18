# Install chocolatey
Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install packages from chocolatey
choco install citrix-receiver -y --allowEmptyChecksums

# Finish up
Write-Output "Finished configuring VM!"

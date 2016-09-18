
$WindowsIsoName = "C:\Users\Claude\Downloads\14393.0.160715-1616.RS1_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US.ISO"

$VMName = "couturier01"
$VHDName = ".\couturier01.vhdx"
$CPUs = 2
$ControlIsoName = ".\couturier.iso"

$UserName = "vagrant"
$Password = "vagrant" | ConvertTo-SecureString -asPlainText -Force

if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) { 
    Stop-VM -Name $VMName -TurnOff -Force -ErrorAction SilentlyContinue -Verbose
    Remove-VM -Name $VMName -Force -Verbose
}

# Create autounattend.iso
if (Test-Path $ControlIsoName) { Remove-Item $ControlIsoName -Force -Verbose }
Write-Verbose -Verbose "Generating $ControlIsoName from contents of 'control' folder"
& "C:\Program Files\Windows AIK\Tools\amd64\oscdimg.exe" -u2 control $ControlIsoName 2>&1 | Out-Null

# Create VM
if (Test-Path $VHDName) { Remove-Item $VHDName -Verbose }
New-VM -Name $VMName `       -NewVHDPath $VHDName -NewVHDSizeBytes 30GB `       -SwitchName Bridge `       -MemoryStartupBytes 4GB `       -Generation 1 `       -Verbose

Set-VMProcessor -VMName $VMName -Count $CPUs

# Attach ISOs
try {
    Set-VMDvdDrive -VMName $VMName -Path $WindowsIsoName -ErrorAction Stop
} catch {
    Write-Error -Message "Unable to attach $WindowsIsoName - aborting."
    exit 100
}

try {
    Add-VMDvdDrive -VMName $VMName -Path $ControlIsoName -ControllerNumber 1
} catch {
    Write-Error -Message "Unable to attach $ControlIsoName - aborting."
    exit 101
}

# Boot VM
Start-VM -Name $VMName -Verbose

Start-Sleep -Seconds 30 -Verbose

# Set up credentials for VM
$Credential = New-Object System.Management.Automation.PSCredential($UserName,$Password)

Remove-Variable Session -ErrorAction SilentlyContinue

# Wait for WinRM
Write-Verbose -Verbose "Waiting for VM..."
while($Iteration -ne 30) {
    $Iteration++

    try {
        # Find VM
        $IpV4Address = ((Get-VMNetworkAdapter -VMName $VMName).IPAddresses)[0]

        if ($IpV4Address) {
            # Kill all remote sessions
            Get-PSSession | Remove-PSSession -Verbose

            # Connect VM
            $Session = New-PSSession -ComputerName $IpV4Address -Credential $Credential
        }

    } catch {}

    if ($Session) {
        Write-Verbose -Verbose "Session to $IpV4Address established!"
        break
    } else {
        Write-Verbose -Verbose "Unreachable - waiting 60 seconds before next attempt ($Iteration/30)..."
        Start-Sleep -Seconds 60
    }
}

if ($Session) {
    Write-Verbose -Verbose "Running .configure.ps1 in VM..."
    Invoke-Command -Session $Session -FilePath .\configure.ps1
} else {
    Write-Error -Message "Fatal: Session to VM could not be established!"
}

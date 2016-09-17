
$WindowsIsoName = "C:\Users\Claude\Downloads\14393.0.160715-1616.RS1_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US.ISO"

$VMName = "couturier01"
$VHDName = ".\couturier01.vhdx"
$CPUs = 2
$ControlIsoName = ".\couturier.iso"

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

# Wait for WinRM





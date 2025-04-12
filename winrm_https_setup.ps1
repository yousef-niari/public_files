# Create a self-signed cert valid for 5 years
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(5)

# Get the thumbprint
$thumb = $cert.Thumbprint

# Create WinRM HTTPS listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname='$env:COMPUTERNAME'; CertificateThumbprint='$thumb'}"

Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false

# Allow HTTPS in firewall
New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "WinRM over HTTPS" -Protocol TCP -LocalPort 5986 -Action Allow

# Allow Basic auth explicitly
winrm set winrm/config/service/Auth '@{Basic="true"}'

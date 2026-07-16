$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

function Repair-CyberArkTemplate {
    param ([string]$Name, [string]$DisplayName, [string]$Source, [bool]$SupplySubject, [bool]$Exportable)

    $RootDSE = Get-ADRootDSE
    $ConfigCtx = $RootDSE.ConfigurationNamingContext
    $TemplatesPath = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigCtx"

    Write-Host "Checking Template: $Name"

    if (-not (Get-ADObject -Filter "Name -eq '$Name'" -SearchBase $TemplatesPath -ErrorAction SilentlyContinue)) {
        Write-Host "  - Template missing. Cloning properties from $Source..."

        $SourceObj = Get-ADObject -Filter "Name -eq '$Source'" -SearchBase $TemplatesPath -Properties *
        if (-not $SourceObj) { Write-Error "Source '$Source' not found!"; return }

        $SchemaAttributes = @(
            'pKIDefaultCSPs', 'pKIDefaultKeySpec', 'pKIKeyUsage',
            'pKIMaxIssuingDepth', 'pKICriticalExtensions', 'pKIExtendedKeyUsage',
            'msPKI-RA-Signature', 'msPKI-Enrollment-Flag', 'msPKI-Private-Key-Flag',
            'msPKI-Certificate-Name-Flag', 'msPKI-Minimal-Key-Size', 'flags', 'revision',
            'pKIExpirationPeriod', 'pKIOverlapPeriod',
            'msPKI-Template-Schema-Version', 'msPKI-Template-Major-Revision', 'msPKI-Template-Minor-Revision'
        )

        $Attributes = @{}
        foreach ($Attr in $SchemaAttributes) {
            if ($SourceObj.$Attr -ne $null) { $Attributes[$Attr] = $SourceObj.$Attr }
        }

        $Attributes['displayName'] = $DisplayName

        if ($SupplySubject) {
            $Current = if ($Attributes['msPKI-Certificate-Name-Flag']) { $Attributes['msPKI-Certificate-Name-Flag'] } else { 0 }
            $Attributes['msPKI-Certificate-Name-Flag'] = $Current -bor 1
        }
        if ($Exportable) {
            $Current = if ($Attributes['msPKI-Enrollment-Flag']) { $Attributes['msPKI-Enrollment-Flag'] } else { 0 }
            $Attributes['msPKI-Enrollment-Flag'] = $Current -bor 16
        }

        New-ADObject -Name $Name -Type pKICertificateTemplate -Path $TemplatesPath -OtherAttributes $Attributes
        Write-Host "  - Created successfully."
    } else {
        Write-Host "  - Template object exists."
    }

    $ADPath = "AD:\CN=$Name,$TemplatesPath"
    $ACL = Get-Acl -Path $ADPath
    $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule((New-Object System.Security.Principal.NTAccount("Authenticated Users")), ([System.DirectoryServices.ActiveDirectoryRights]"GenericRead, ExtendedRight"), [System.Security.AccessControl.AccessControlType]::Allow)
    $ACL.AddAccessRule($Rule)
    Set-Acl -Path $ADPath -AclObject $ACL
}

Repair-CyberArkTemplate -Name 'CyberArkWebServer' -DisplayName 'CyberArk Web Server' -Source 'WebServer' -SupplySubject $true -Exportable $true
Repair-CyberArkTemplate -Name 'CyberArkUser' -DisplayName 'CyberArk User Auth' -Source 'User' -SupplySubject $false -Exportable $true
Repair-CyberArkTemplate -Name 'CyberArkPSM' -DisplayName 'CyberArk PSM Remote Desktop' -Source 'WebServer' -SupplySubject $true -Exportable $true

Restart-Service CertSvc
certutil -SetCATemplates +CyberArkWebServer | Out-Null
certutil -SetCATemplates +CyberArkUser | Out-Null
certutil -SetCATemplates +CyberArkPSM | Out-Null
certutil -SetCATemplates +User | Out-Null
certutil -SetCATemplates +Workstation | Out-Null
Restart-Service CertSvc

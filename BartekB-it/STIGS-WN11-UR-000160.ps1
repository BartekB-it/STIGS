<#
.SYNOPSIS
    This PowerShell script ensures that only Administrators are able to "Restore files and directories".

.NOTES
    Author          : Bartłomiej Biskupiak
    LinkedIn        : www.linkedin.com/in/bartłomiej-biskupiak
    GitHub          : github.com/BartekB-it
    Date Created    : 2025-11-14
    Last Modified   : 2025-11-14
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000160

.USAGE
    PS C:\> .\__remediation_template(WN11-AU-000160).ps1 
#>

# Run in an elevated (Run as administrator) PowerShell

$cfg = "$env:TEMP\secpol_restore_set.inf"

# 1) Export current user rights configuration
secedit /export /cfg $cfg /areas USER_RIGHTS | Out-Null

# Backup the original INF file just in case
Copy-Item $cfg "$cfg.bak" -Force

# Load the file
$content = Get-Content $cfg

# Change or add the SeRestorePrivilege line
if ($content -match '^SeRestorePrivilege') {
    $content = $content -replace '^SeRestorePrivilege.*','SeRestorePrivilege = *S-1-5-32-544'
} else {
    $content += 'SeRestorePrivilege = *S-1-5-32-544'
}

# Save the modified INF file
$content | Set-Content $cfg -Encoding Unicode

# Apply the configuration back to Local Security Policy
secedit /configure /db "$env:TEMP\secpol_restore.sdb" /cfg $cfg /areas USER_RIGHTS /overwrite | Out-Null

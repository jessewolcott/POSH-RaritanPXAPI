#Requires -Version 5.1

# POSH-RaritanPXAPI.psm1
# PowerShell module for interacting with Raritan PX API

# Module variables
$script:ModuleRoot = $PSScriptRoot
$script:LogPath = Join-Path -Path $script:ModuleRoot -ChildPath "Logs"
$script:CredentialPath = Join-Path -Path $script:ModuleRoot -ChildPath "Credentials"
$script:LoggingEnabled = $false
$script:LogFile = $null

#region Module Initialization
function Initialize-RPXAPIModule {
    # Create Logs directory if it doesn't exist
    if (-not (Test-Path -Path $script:LogPath)) {
        try {
            New-Item -Path $script:LogPath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created Logs directory at $script:LogPath"
        }
        catch {
            Write-Error "Failed to create Logs directory: $_"
        }
    }

    # Create Credentials directory if it doesn't exist
    if (-not (Test-Path -Path $script:CredentialPath)) {
        try {
            New-Item -Path $script:CredentialPath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created Credentials directory at $script:CredentialPath"
        }
        catch {
            Write-Error "Failed to create Credentials directory: $_"
        }
    }
}

# Run initialization when the module is imported
Initialize-RPXAPIModule
#endregion

#region Logging Functions
function Enable-RPXAPILogging {
    <#
    .SYNOPSIS
        Enables logging for the POSH-RaritanPXAPI module.
    .DESCRIPTION
        Enables logging for all functions in the POSH-RaritanPXAPI module. Logs are stored in the /Logs folder.
    .PARAMETER LogFilePath
        Optional. Specify a custom log file path. If not specified, a default log file with timestamp will be created.
    .EXAMPLE
        Enable-RPXAPILogging
    .EXAMPLE
        Enable-RPXAPILogging -LogFilePath "C:\CustomLogs\RaritanPX.log"
    #>
    [CmdletBinding()]
    param (
        [string]$LogFilePath
    )

    try {
        if (-not $LogFilePath) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $LogFilePath = Join-Path -Path $script:LogPath -ChildPath "RPXAPI_$timestamp.log"
        }
        
        # Create log file if it doesn't exist
        if (-not (Test-Path -Path $LogFilePath)) {
            $null = New-Item -Path $LogFilePath -ItemType File -Force
        }
        
        $script:LogFile = $LogFilePath
        $script:LoggingEnabled = $true
        
        Write-Verbose "Logging enabled. Log file: $script:LogFile"
        Write-RPXAPILog -Message "Logging initialized for POSH-RaritanPXAPI module"
    }
    catch {
        Write-Error "Failed to enable logging: $_"
        $script:LoggingEnabled = $false
    }
}

function Disable-RPXAPILogging {
    <#
    .SYNOPSIS
        Disables logging for the POSH-RaritanPXAPI module.
    .DESCRIPTION
        Disables the logging functionality for the module.
    .EXAMPLE
        Disable-RPXAPILogging
    #>
    [CmdletBinding()]
    param()
    
    if ($script:LoggingEnabled) {
        Write-RPXAPILog -Message "Logging disabled for POSH-RaritanPXAPI module"
        $script:LoggingEnabled = $false
        $script:LogFile = $null
        Write-Verbose "Logging has been disabled"
    }
    else {
        Write-Verbose "Logging is already disabled"
    }
}

function Write-RPXAPILog {
    <#
    .SYNOPSIS
        Writes a message to the POSH-RaritanPXAPI log file.
    .DESCRIPTION
        Writes a message to the log file if logging is enabled.
    .PARAMETER Message
        The message to write to the log file.
    .PARAMETER Level
        The log level (INFO, WARNING, ERROR).
    .EXAMPLE
        Write-RPXAPILog -Message "This is a log message" -Level INFO
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    if ($script:LoggingEnabled -and $script:LogFile) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        try {
            Add-Content -Path $script:LogFile -Value $logEntry
        }
        catch {
            Write-Error "Failed to write to log file: $_"
        }
    }
}

function Get-RPXAPILogPath {
    <#
    .SYNOPSIS
        Gets the current log file path for the POSH-RaritanPXAPI module.
    .DESCRIPTION
        Returns the path to the current log file if logging is enabled.
    .EXAMPLE
        Get-RPXAPILogPath
    #>
    [CmdletBinding()]
    param()
    
    if ($script:LoggingEnabled -and $script:LogFile) {
        return $script:LogFile
    }
    else {
        Write-Verbose "Logging is not currently enabled"
        return $null
    }
}
#endregion

#region Credential Management Functions
function Set-RPXAPICredential {
    <#
    .SYNOPSIS
        Sets credentials for connecting to Raritan PX API.
    .DESCRIPTION
        Stores credentials securely for use with the Raritan PX API. Credentials are stored in the /Credentials folder.
    .PARAMETER Name
        The name to identify this set of credentials.
    .PARAMETER Credential
        The PSCredential object containing username and password.
    .PARAMETER ApiEndpoint
        The URL of the Raritan PX API endpoint.
    .EXAMPLE
        $cred = Get-Credential
        Set-RPXAPICredential -Name "PX1" -Credential $cred -ApiEndpoint "https://px1.example.com/api"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential,
        
        [Parameter(Mandatory = $true)]
        [string]$ApiEndpoint
    )
    
    try {
        # Create credential object with additional properties
        $credInfo = @{
            Username = $Credential.UserName
            ApiEndpoint = $ApiEndpoint
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        # Create file paths
        $credFileName = "$Name.xml"
        $credInfoFileName = "$Name.json"
        $credFilePath = Join-Path -Path $script:CredentialPath -ChildPath $credFileName
        $credInfoFilePath = Join-Path -Path $script:CredentialPath -ChildPath $credInfoFileName
        
        # Export credentials securely
        $Credential.Password | ConvertFrom-SecureString | Export-Clixml -Path $credFilePath -Force
        
        # Export credential info (without the password)
        $credInfo | ConvertTo-Json | Set-Content -Path $credInfoFilePath -Force
        
        Write-RPXAPILog -Message "Credentials stored for '$Name'"
        Write-Verbose "Credentials for '$Name' have been stored successfully"
    }
    catch {
        Write-RPXAPILog -Message "Failed to store credentials for '$Name': $_" -Level ERROR
        Write-Error "Failed to store credentials: $_"
    }
}

function Get-RPXAPICredential {
    <#
    .SYNOPSIS
        Retrieves stored credentials for connecting to Raritan PX API.
    .DESCRIPTION
        Gets the stored credentials for use with the Raritan PX API.
    .PARAMETER Name
        The name of the credential set to retrieve.
    .EXAMPLE
        $cred = Get-RPXAPICredential -Name "PX1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    try {
        # Define file paths
        $credFileName = "$Name.xml"
        $credInfoFileName = "$Name.json"
        $credFilePath = Join-Path -Path $script:CredentialPath -ChildPath $credFileName
        $credInfoFilePath = Join-Path -Path $script:CredentialPath -ChildPath $credInfoFileName
        
        # Check if files exist
        if (-not (Test-Path -Path $credFilePath) -or -not (Test-Path -Path $credInfoFilePath)) {
            Write-RPXAPILog -Message "Credentials not found for '$Name'" -Level WARNING
            Write-Error "Credentials not found for '$Name'"
            return $null
        }
        
        # Import credential info
        $credInfo = Get-Content -Path $credInfoFilePath -Raw | ConvertFrom-Json
        
        # Import password from secure storage
        $passwordSecureString = Get-Content -Path $credFilePath | ConvertTo-SecureString
        
        # Create and return credential object with additional properties
        $credential = New-Object System.Management.Automation.PSCredential($credInfo.Username, $passwordSecureString)
        
        $result = [PSCustomObject]@{
            Name = $Name
            Credential = $credential
            ApiEndpoint = $credInfo.ApiEndpoint
            Timestamp = $credInfo.Timestamp
        }
        
        Write-RPXAPILog -Message "Retrieved credentials for '$Name'"
        return $result
    }
    catch {
        Write-RPXAPILog -Message "Failed to retrieve credentials for '$Name': $_" -Level ERROR
        Write-Error "Failed to retrieve credentials: $_"
        return $null
    }
}

function Get-RPXAPICredentialList {
    <#
    .SYNOPSIS
        Lists all stored Raritan PX API credentials.
    .DESCRIPTION
        Returns a list of all credential sets stored for use with the Raritan PX API.
    .EXAMPLE
        Get-RPXAPICredentialList
    #>
    [CmdletBinding()]
    param()
    
    try {
        $credentialFiles = Get-ChildItem -Path $script:CredentialPath -Filter "*.json" -ErrorAction SilentlyContinue
        
        $credentialList = foreach ($file in $credentialFiles) {
            $name = $file.BaseName
            $credInfo = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
            
            [PSCustomObject]@{
                Name = $name
                Username = $credInfo.Username
                ApiEndpoint = $credInfo.ApiEndpoint
                Timestamp = $credInfo.Timestamp
            }
        }
        
        Write-RPXAPILog -Message "Retrieved credential list"
        return $credentialList
    }
    catch {
        Write-RPXAPILog -Message "Failed to retrieve credential list: $_" -Level ERROR
        Write-Error "Failed to retrieve credential list: $_"
        return $null
    }
}

function Remove-RPXAPICredential {
    <#
    .SYNOPSIS
        Removes stored credentials for Raritan PX API.
    .DESCRIPTION
        Deletes the stored credentials for the specified name.
    .PARAMETER Name
        The name of the credential set to remove.
    .EXAMPLE
        Remove-RPXAPICredential -Name "PX1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    try {
        # Define file paths
        $credFileName = "$Name.xml"
        $credInfoFileName = "$Name.json"
        $credFilePath = Join-Path -Path $script:CredentialPath -ChildPath $credFileName
        $credInfoFilePath = Join-Path -Path $script:CredentialPath -ChildPath $credInfoFileName
        
        # Remove files if they exist
        if (Test-Path -Path $credFilePath) {
            Remove-Item -Path $credFilePath -Force
        }
        
        if (Test-Path -Path $credInfoFilePath) {
            Remove-Item -Path $credInfoFilePath -Force
        }
        
        Write-RPXAPILog -Message "Removed credentials for '$Name'"
        Write-Verbose "Credentials for '$Name' have been removed"
    }
    catch {
        Write-RPXAPILog -Message "Failed to remove credentials for '$Name': $_" -Level ERROR
        Write-Error "Failed to remove credentials: $_"
    }
}
#endregion

#region Authentication Functions
function Get-RPXAPIToken {
    <#
    .SYNOPSIS
        Gets authentication headers for the Raritan PX API using Basic Authentication.
    .DESCRIPTION
        Creates authentication headers using stored credentials for use with the Raritan PX API.
    .PARAMETER CredentialName
        The name of the stored credential set to use.
    .EXAMPLE
        $authHeaders = Get-RPXAPIToken -CredentialName "PX1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$CredentialName
    )
    
    try {
        # Get stored credentials
        $credentialInfo = Get-RPXAPICredential -Name $CredentialName
        
        if ($null -eq $credentialInfo) {
            Write-RPXAPILog -Message "Failed to get authentication: Credentials not found for '$CredentialName'" -Level ERROR
            Write-Error "Credentials not found for '$CredentialName'"
            return $null
        }
        
        $credential = $credentialInfo.Credential
        $apiEndpoint = $credentialInfo.ApiEndpoint
        
        # Get username and password
        $username = $credential.UserName
        $password = $credential.GetNetworkCredential().Password
        
        # Encode the credentials to Base64
        $encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($username)+':'+($password)))
        
        Write-RPXAPILog -Message "Generated Basic Authentication header for '$CredentialName'"
        
        # Create and return the headers
        $authHeaders = @{
            Authorization = "Basic $encodedCredentials"
            "Content-Type" = "application/json"
        }
        
        # Return authentication information
        return [PSCustomObject]@{
            Headers = $authHeaders
            ApiEndpoint = $apiEndpoint
            CredentialName = $CredentialName
        }
    }
    catch {
        Write-RPXAPILog -Message "Failed to create authentication headers: $_" -Level ERROR
        Write-Error "Failed to create authentication headers: $_"
        return $null
    }
}

function Test-RPXAPIToken {
    <#
    .SYNOPSIS
        Tests if authentication credentials for the Raritan PX API are valid.
    .DESCRIPTION
        Verifies if the provided authentication credentials are valid by making a test API call.
    .PARAMETER AuthInfo
        The authentication information object returned by Get-RPXAPIToken.
    .EXAMPLE
        $authInfo = Get-RPXAPIToken -CredentialName "PX1"
        Test-RPXAPIToken -AuthInfo $authInfo
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$AuthInfo
    )
    
    try {
        if ($null -eq $AuthInfo) {
            Write-RPXAPILog -Message "Authentication validation failed: AuthInfo is null" -Level ERROR
            return $false
        }
        
        # Construct test endpoint
        $testEndpoint = "$($AuthInfo.ApiEndpoint)/test"
        
        # Make test request using the Basic Authentication headers
        $response = Invoke-RestMethod -Uri $testEndpoint -Method Get -Headers $AuthInfo.Headers -ErrorAction Stop
        
        Write-RPXAPILog -Message "Authentication validation successful"
        return $true
    }
    catch {
        Write-RPXAPILog -Message "Authentication validation failed: $_" -Level ERROR
        Write-Verbose "Authentication validation failed: $_"
        return $false
    }
}

#endregion

# Export module functions
Export-ModuleMember -Function @(
    # Logging Functions
    'Enable-RPXAPILogging',
    'Disable-RPXAPILogging',
    'Write-RPXAPILog',
    'Get-RPXAPILogPath',
    
    # Credential Management Functions
    'Set-RPXAPICredential',
    'Get-RPXAPICredential',
    'Remove-RPXAPICredential',
    'Get-RPXAPICredentialList',
    
    # Authentication Functions
    'Get-RPXAPIToken',
    'Test-RPXAPIToken'
)

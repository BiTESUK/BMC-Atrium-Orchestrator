Function New-BAOConnection{
<#
    .SYNOPSIS
    Creates an authenticated session to a BMC AO Grid.

    .DESCRIPTION
    Creates an authenticated session to the AO Grid. Executing this function
    will populate the Global variable BMC_AO_Token which is an instance
    of a custom Token information.

    This Function will default to an HTTP connection but can be overridden.

    See Examples for more details and usage.

    .PARAMETER Fqdn
    [string]    -    The Fully Qualified Domain Name.
    
        Default Setting - my.test.server.com
    
    .PARAMETER Port
    [int]       -   The port number for the grid
                    Default: 38080

    .PARAMETER Credential
    [PSCredential]    -    Supply Alternative Credentials

    .PARAMETER Secure
    [Switch]    -   Creates an HTTPS Connection
                    Default: HTTP

    .EXAMPLE
    New-BAOConnection

    Connects to the default Uri

    .EXAMPLE
    New-BAOConnection -Credential (Get-Credential)

    Connects to the default Uri with the credential object passed.

    .EXAMPLE
    New-BAOConnection -Fqdn 'some.server.on.domain'

    Connects to the grid instance on 'some.server.on.domain:38080'

    .EXAMPLE
    New-BAOConnection -Fqdn 'some.server.on.domain' -Por 1234

    Connects to the grid instance on 'some.server.on.domain:1234'

#>
    [cmdletbinding(SupportsShouldProcess=$true)]
    [OutputType([System.Management.Automation.PSObject])]
    param(
        [Parameter(ValueFromPipeline =$true,
            ValueFromPipelineByPropertyName = $True)]
        [Alias("h")]
        #[ValidateNotNullOrEmpty()]
        [String]$Host ='my.test.host.net',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("p")]
        [int]$Port = 38080,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('s')]
        [switch]$Secure = $False,

        [Parameter(Mandatory = $False,
            ValueFromPipelineByPropertyName = $True)]
        [Alias("c")]
        #[ValidateNotNullOrEmpty()] - AGAIN THIS VALIDATION SHOULD BE ACTIVE
        [PSCredential]$Credential = $SCRIPT:CREDENTIAL
    )
    
    BEGIN { 
        <# Check Token Validity #>
        if (($GLOBAL:BMC_AO_TOKEN.Authenticated) -and (-not $GLOBAL:BMC_AO_TOKEN.TokenExpired)) {
            Throw 'Session is already authenticated.\r\nPlease use the $BMC_AO_Token Variable.';
            exit;
        };
        <# Build up our GRID URL. #>
        $SCRIPT:URL_GRID = $($SCRIPT:URL_GRID -f $Host, $Port);

        if($Secure.IsPresent) {
            # Use a simple replace of HTTP with HTTPS
            $SCRIPT:URL_GRID = $($SCRIPT:URL_GRID -ireplace 'http', 'https');
        };

        <# Allow Selfsigned Certs #>
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True; };

        <# Build up our JSON Authentication Payload #>
        $PAYLOAD = @"
{
    "username": "$($Credential.Username)",
    "password": "$($Credential.GetNetworkCredential().Password)"
}
"@;

    };

    PROCESS {
        <# Setup some default vars for use in this script #>
        $Response = [string]::Empty;
    
        Try {
            $Response = Invoke-WebRequest -Uri $URL_GRID$URL_LOGIN -Body $PAYLOAD -Method Post -ContentType $CONTENT_TYPE;
            
            <#  A 200 return code is merely that the request succeeded.
                not that it actually authenticated. For this we can check the Login
                property is populated.

                TODO: Convert validation to utilise internal CheckResponse function.
            #>

            If (($Response.StatusCode -eq 200) -and (($Response.Content | ConvertFrom-Json).Login)) {
                $GLOBAL:BMC_AO_TOKEN.Authenticated = $True;
            };
        } catch {
            throw $Response;
        };
    };

    END {
        If ($GLOBAL:BMC_AO_TOKEN.Authenticated) {
            <# Build out our GOAL.BMC_AO_Token object for use through out the infra #>
            $GLOBAL:BMC_AO_TOKEN.Credential = $Credential;
            $GLOBAL:BMC_AO_TOKEN.Token = $Response.Headers.'Authentication-Token';
            $GLOBAL:BMC_AO_TOKEN.TimeStamp = $Response.Headers.Date;
            $GLOBAL:BMC_AO_TOKEN.GridUri = $Response.BaseResponse.ResponseUri;
        };
       
        Remove-Variable ("Response") -Force;
        return $GLOBAL:BMC_AO_TOKEN;
    };
};
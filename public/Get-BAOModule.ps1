Function Get-BAOModule {
<#
    .SYNOPSIS
    Retrieves AO Modules from the connected grid.

    .DESCRIPTION
    Retrieves AO Modules from the connected grid.
    Needs a valid GOAL.BMC_AO_Token to be populated with
        New-BAOConnection

    .PARAMETER Repository
    [switch]    -    Use to query Modules in the repository.

    .EXAMPLE
    Get-BAOModules

    Retrieves Modules available to the connected Grid.

    .EXAMPLE
    Get-BAOModules -Repository

    Retrieves Modules avalable to the connected Grid Repository.
#>
    [cmdletBinding(SupportsShouldProcess=$true,
        DefaultParameterSetName="Global")]
    param(
        [parameter(ValueFromPipeLine = $true,
            ValueFromPipeLineByPropertyName=$true,
            HelpMessage="Use to query Modules in the Repository.")]
        [switch]$Repository,

        [parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="Token")]
        [GOAL.BMC_AO_Token]$Token=$Global:BMC_AO_Token,
        
        [parameter(ValueFromPipelineByPropertyName=$true,
            ParameterSetName="Credential")]
        [System.Management.Automation.PSCredential]$Credential       
    )

    BEGIN {
        if($PSCmdlet.ParameterSetName -ieq "Token") {
            <# User has passed in a GOAL.BMC.AO.Token Object #>
            If(-not ($Token.Authenticated) -and ($Token.TokenExpired)) {
                throw "Connection is not authenticated. Please createa token with:`r`nNew-BAOConnection.";
                break;
            }
        } elseif ($PSCmdlet.ParameterSetName -ieq "Credential") {
            <# User has passed in a PSCredential Object so recreate our Global BMC_AO_TOKEN #>
            $credential | New-BAOConnection;
        } else {
            <# User has not passed anything so use the existing BMC_AO_Token information #>
            if (-not($GLOBAL:BMC_AO_TOKEN.Authenticated) -or ($GLOBAL:BMC_AO_TOKEN.TokenExpired)) {
                throw "Connection is not authenticated. Please create a token with:`r`nNew-BAOConnection.";
                break;
            };
        };
    };

    PROCESS {
        $Uri = "$URL_GRID$URL_MODULE";
        if ($Repository.IsPresent) {
            $Uri += "?repo=true";
        };
        
        REST.ExecuteRequest -Uri $Uri `
            -Method [System.Net.WebRequestMethod]::Get
            -SessionInfo $GLOBAL:BMC_AO_TOKEN `
            -ContentType $SCRIPT:CONTENT_TYPE | ConvertFrom-JSON;
    };
   
    END {
        Remove-Variable 'Uri' -Force;
    };
};

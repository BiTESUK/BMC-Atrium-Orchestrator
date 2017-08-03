function REST.ExecuteRequest {
    [CMDLetBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [BiTES.BMC_AO_Token]$BMC_AO_TOKEN,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        #[ValidateSet('get', 'post')]
        [System.Net.WebRequestMethods]$Method,

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ContentType,

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Payload
    )

    BEGIN {
        <# Validate that we are authenticated #>
        if(-not ($BMC_AO_TOKEN.Authenticated) -or ($BMC_AO_TOKEN.TokenExpired)) {
            try {
                New-BAOConnection;
            } catch {
                throw 'Not Authenticated to Grid. Please create a connection with New-BAOConnection'
                break;
            };
        };
    }

    PROCESS {
        <# Make sure our BMC_AO_TOKEN.Token has a value #>
        if(-not ($BMC_AO_TOKEN.Authenticated) -or ($BMC_AO_TOKEN.TokenExpired)) {
            throw 'Invalid Session Information. Please create a connection with New-BAOConnection';
            break;
        };

        try {
            <# Execute Request #>
            Write-debug $Uri
            Write-Verbose $BMC_AO_TOKEN.Token

            $Response = Invoke-WebRequest -Uri $Uri -Method $Method `
                                            -ContentType $ContentType `
                                            -Headers @{"Authentication-Token"=$BMC_AO_TOKEN.Token}

            <# Use the internal helper for response validation #>
            If(REST.CheckResponse -response $Response) {
                return $Response;
            } else {
                return $false;
            };

        } catch {
            throw;
            break;
        };
    };

    END {
        Remove-Variable ('Response') -Force;        
    };
};

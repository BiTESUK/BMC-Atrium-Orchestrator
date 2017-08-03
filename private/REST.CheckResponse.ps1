function REST.CheckResponse {
    [CMDLetBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="Default")]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.HtmlWebResponseObject]$Response,

        [Parameter(ValueFromPipeLineByPropertyName=$true,
            ParameterSetName="CustomCodes")]
        [int[]]$Codes,

        [Parameter(ValueFromPipelineByPropertyName=$true,
            ParameterSetName="CustomMessages")]
        [string[]]$Messages

    )
    BEGIN {
        # Populate a default return value
        $ReturnStatus = $false;
    }

    PROCESS {
        if($PSCmdlet.ParameterSetName -eq 'Default') {
            if ($Response.StatusCode -eq 200 -or $Response.StatusDescription -eq 'OK') {
                $ReturnStatus = $true;
            } else {
                return $ReturnStatus;
            };
        };

        # TODO: TEST THIS
        if($PSCmdlet.ParameterSetName -eq 'CustomCodes') {
            If($Response.StatusCode -in $Codes) {
                $ReturnStatus = $ReturnStatus -band $true;
            } else {
                $ReturnStatus = $ReturnStatus -band $false;
            };
        };
    
        # TODO: TEST THIS
        if($PSCmdlet.ParameterSetName -eq 'CustomMessages') {
            if($Response.StatusDescription -in $Messages) {
                $ReturnStatus = $ReturnStatus -band $true;
            } else {
                $ReturnStatus = $ReturnStatus -band $false;
            }
        };
    };

    END {
        return $ReturnStatus;
    }
};

Function Get-BAOProcess {


    if (($GLOBAL:BMC_AO_TOKEN.Authenticated) -and (-not $GLOBAL:BMC_AO_TOKEN.TokenExpired)) {
        Write-Verbose "Uri:`t$URL_GRID$URL_PROCESS"
        Write-Verbose "Content:`t$SCRIPT:CONTENT_TYPE"
        Write-Verbose "Token:`t$GLOBAL:BMC_AO_TOKEN"
        
        REST.ExecuteRequest -Uri $URL_GRID$URL_PROCESS `
            -Method get `
            -SessionInfo $GLOBAL:BMC_AO_TOKEN `
            -ContentType $SCRIPT:CONTENT_TYPE | ConvertFrom-JSON
    } else {
        throw "Connection not Authenticated. Please create a token with:`r`nNew-BAOConnection";
    }
};

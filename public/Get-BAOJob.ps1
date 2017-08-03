Function Get-BAOJob {
    if (($GLOBAL:BMC_AO_TOKEN.Authenticated) -and (-not $GLOBAL:BMC_AO_TOKEN.TokenExpired)) {
        Write-host "Execuuting $URL_GRID$URL_JOB"

        REST.ExecuteRequest -Uri $URL_GRID$URL_JOB `
            -Method get `
            -SessionInfo $GLOBAL:BMC_AO_TOKEN `
            -ContentType $SCRIPT:CONTENT_TYPE | ConvertFrom-JSON

    } else {
        throw "Connection not Authenticated. Please create a token with:`r`nNew-BAOConnection";
    }
};

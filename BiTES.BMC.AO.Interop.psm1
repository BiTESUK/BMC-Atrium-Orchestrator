<#

    Module Content:

    Function Name          Category             Access
    -------------          ---------            -------
    New-BAOConnection      BMC.AO.Token         Public
    Get-BAOModules         BMC.AO.Module        Public
    Get-BAOWorkflow        BMC.AO.Workflow      Public

    -------------          ---------            -------
    REST.ExecuteRequest    Wrapper              Private
    REST.CheckResponse     Utility              Private



    .DESCRIPTION

    This module manages HTTP/S Connections and wraps REST API Calls for BMC Atrium Orchestrator

    .VERSION
        0.5

    .AUTHOR
        Al James

    .HISTORY
        0.5        -        Refactored Module for source code segregation\management\versioning
        0.4        -        Added Regular Expression for identifying Grid Port
                            Added Readonly Boolean Property in C# Class 'TokenExpired'
                                to allow for a simple evaluation of Token Validity
                            Updated internal variable names
                            Removed unused variables
        0.3        -        Extended C# class with Private\Public accesors to allow
                                Default 1 Hr token time
                                Extraction of the Grid Port from the Uri (should be regex, but this is a split)
        0.2        -        Added ExecuteRestMethod Private Function
                            Added CheckResponse Private Function
                            Added Get-BAOModules Public Function
                            Added C# Class to replace CustomPSObject 
                                TypeName GOAL.BMC_AO_Token can be idenitifed\Bound in Parameter Binding
        0.1        -        Initial Draft
#>


#region GLOBAL Variables

<# HASHED PASSWORD: This should potentially be managed by
    CyberarkArk and a wrapper implemented for credential retrieval.

    For the purposes of testing this hash is created from the 
    password for the account nbkajsa - this is clearly bad!
#>
$GLOBAL:SECURE_HASH = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000004bb55b1cdfabaf4797f8062f08de58290000000002000000000003660000c00000001000000045a25e33e9aabca8b8a10c0a71ac1d630000000004800000a0000000100000007ffb85a18f271a9b1dc7cad39e0c81a818000000a4722e639045117c7362364888b30ba137779d7814cff25214000000d32eba58134ef5d2deebf7d1c3974a815f54ab6c";
$GLOBAL:CALLER = "**********";

<# Create a PSScriptRoot for Testing live would run from 
    the module, so would populate correctly #>

<# This would be better with a Class so you can 
    easily identify this object by its Type and
    manage some ReadOnly properties. You could
    achieve this with Powershell v5 Classes, or
    this could be implemented with Powershell 
    ScriptMethods, but would make code complex.

    Example Code for Powershell v3.0 and below.

$GLOBAL:BMC_AO_TOKEN = [PSCustomObject]@{
    Token = [string]::Empty;
    Date = [Datetime];
    Credential = [PSCredential];
    Authenticated = $false;
};

#>

Write-Host "Importing Library..."
try {
    (Get-ChildItem $PSScriptRoot\lib -Filter '*.ps1') | % {
        Import-Module $_.Fullname -force;
        Write-Host "`tImported:`t$($_.BaseName)";
    }
} catch {
    throw "FATAL Error Importing GOAL.BMC.AO.Token Object.`r`n$_";
    exit;
}

<# Create a Global Var of Type GOAL.BMC_AO_Token #>
Write-Host "Creating Global Operations Analytics Components..."
$GLOBAL:BMC_AO_TOKEN = New-Object GOAL.BMC_AO_Token

#endregion

#region SCRIPT Variables

<# This is used for development only and should be removed #>
$SCRIPT:CREDENTIAL = New-Object System.Management.Automation.PSCredential -ArgumentList ($CALLER, ($SECURE_HASH | ConvertTo-SecureString));

#endregion

#region BAO Configuration

<# Configuration of the core BMC AO portal #>
$SCRIPT:URL_GRID = "http://{0}:{1}/baocdp/rest";
$SCRIPT:URL_LOGIN = "/login";
$SCRIPT:URL_MODULE = "/module";
$SCRIPT:URL_PROCESS = "/process";
$SCRIPT:URL_JOB = "/job"; 

<# Configuration of the JSON Payload #>
$SCRIPT:CONTENT_TYPE = "application/json";

#endregion

#region Import Public Methods

Write-Host "Building Pulic Methods..."
(Get-ChildItem -Path $PSScriptRoot\public -Filter '*.ps1') | % {
    try {
        Import-Module $_.FullName -Force;
        Write-Host "`tBuilt:`t$($_.BaseName)`r`n`t`tCreating Accessor..."
        Export-ModuleMember -Function $_.BaseName
        write-host "`t`tSuccess."
    } catch {
        throw "Error Creating Public Functions`r`n$_"
        exit;
    };
};

#endregion

#region Import Private Methods
Write-Host "Building Private Methods..."
(Get-ChildItem -Path $PSScriptRoot\private -Filter '*.ps1') | % {
    try {
        Import-Module $_.FullName -Force
        Write-Host "`tBuilt:`t$($_.BaseName)";
    } catch {
        throw "Error Creating Private Methods`r`n$_";
        exit;
    }
}

#endregion
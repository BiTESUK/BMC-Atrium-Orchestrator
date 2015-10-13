#Requires -Version 2
Set-StrictMode -Version Latest;
Add-Type -Assembly PresentationCore;

[string]$Script:ERR_NO_CLIP = "Unable to load Clipboard:`t{0}";

function Get-ClipBoardText{
<#
  .SYNOPSIS
    Retrieves the current clipboard text
  .DESCRIPTION
    Utilises the Windows.Clipboard object from the .NET Class PresentationCore
  .PARAMETER Raw
    Flag to indicate if raw data read from the clipboard is passed back.
    Default set to TRUE
  .EXAMPLE
    PS C:\> Get-ClipBoardText
  .EXAMPLE
    PS c:\> Get-ClipBoardText -Raw
  .LINK
    Clipboard Class
    https://msdn.microsoft.com/en-us/library/system.windows.clipboard(v=vs.110).aspx
#>
  [CmdletBinding()]
  Param(
    [Parameter(Position=0,
        ValueFromPipeLine=$true)]
      [switch]$Raw=$True
  )
  
  BEGIN {
    Try {
      $Return = [Windows.Clipboard]::GetText();
    } catch {
      throw $($Script:ERR_NO_CLIP -f $_);
    };
  };
  
  PROCESS {
    if (!$Raw) {
      $Return = $($Return -split '\r?\n');
    };
  };
  
  END {
    return $Return;
  };
};  # Get-ClipBoardText
  
function Set-ClipBoardText {
<#
  .SYNOPSIS
    Sets the text in the clipboard
  .DESCRIPTION
    Overwrites existing clipboard data with the new string data in InputObject
    if using the Append switch, text is appended to the existing clipboard data.
  .PARAMETER InputObject
    The Text to set the clipboard buffer to
  .PARAMETER Seperator
    Use for a custom seperator
    Default is set to [System.Environment]::NewLine
  .PARAMETER Terminator
    No this is not to do with Skynet, use for a custom string termination
    Default is set to [System.Environment]::NewLine
  .EXAMPLE
    PS C:\> Add-ClipBoardText -InputObject 'Some String Data' -Separator ':' -Append
  .EXAMPLE
    PS C:\> Add-ClipBoardText -InputObject 'Some String Data' -Separator ';'
  .EXAMPLE
    PS C:\> Add-ClipBoardText -InputObject 'Some String Data'
  .LINK
    https://msdn.microsoft.com/en-us/library/ms597043(v=vs.110).aspx
#>
  [CmdletBinding(DefaultParameterSetName='S')]
  Param(
    [Parameter(Mandatory=$true,
              Position=0,
              ValueFromPipeline=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$InputObject,
    [Parameter(ParameterSetName = 'S')]
      [string]$Separator = [System.Environment]::NewLine,
    [Parameter(ParameterSetName = 'T')]
      [string]$Terminator = [System.Environment]::NewLine,
    [Parameter(ValueFromPipeLine=$True)]
    [switch]$Append=$False
  )
  
  BEGIN {
    [System.Text.StringBuilder]$SB = [string]::Empty;
  };
  
  PROCESS {
    $SB.Append($InputObject) | Out-Null;
    if ($PSCmdlet.ParameterSetName -ieq 's') {
      $SB.Append($Separator) | Out-Null;
    } else {
      $SB.Append($Terminator) | Out-Null;
    }
    # Remove the trailing seperator\terminator
    if (($PSCmdlet.ParameterSetName -ieq 's') -and ($SB.Length -ge 1)) {
      $SB.Length -= $Separator.Length;
    } else {
      $SB.Length -= $Terminator.Length;
    };
  };
  
  END {
    Try {
      if ($Append) {
        $Existing = Get-ClipBoardText;
        [Windows.Clipboard]::SetText($Existing + [System.Environment]::NewLine + `
          ($SB.ToString() -replace '(?<!\r)\n', [System.Environment]::NewLine));
      } else {
        [Windows.Clipboard]::SetText(($SB.ToString() -replace '(?<!\r)\n'. [System.Environment]::NewLine));
      };
    } catch {
      Return $_;
    }
  };
};  # Add-ClipBoardText

function Clear-ClipBoard{
<#
  .SYNOPSIS
    Clears the content of the windows clipboard
  .DESCRIPTION
    Clears the content of the windows clipboard
  .EXAMPLE
    PS C:\> Clear-ClipBoard
  .NOTES
    This function doesn't produce any output unless an error is thrown.
#>
  try {
    [System.Windows.Clipboard]::Clear();
  } catch {
    Return $_;
  };
};  # Clear-ClipBoard

#Export-ModuleMember -Function Get-ClipBoardText
#Export-ModuleMember -Function Set-ClipBoardText
#Export-ModuleMember -Function Clear-ClipBoard

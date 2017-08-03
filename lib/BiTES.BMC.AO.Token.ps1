<# Add The TypeDef You can reference with GOAL.BMC_AO_Token
    We also use RegEx in this code, so ensure that dependencies are
    imported via the -UsingNamespace property (which takes an array)
    if you do not do this, you need to wrap a fully crafted class
    with appropriate namespaces and utilise parameter -TypeDefinition
    
        N.B. The following namespaces are imported automatically

            Command                   Namespace
            -------                   ---------
            Add-Type             -    System
            -MemberDefinition    -    System.Runtime.InteropServices

https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/add-type

#>

Add-Type -Namespace BiTES -Name BMC_AO_Token `
    -UsingNamespace System.Text.RegularExpressions `
    -MemberDefinition @"
    private string _Token = string.Empty;
    private System.DateTime _Timestamp;
    private System.Management.Automation.PSCredential _Credential;
    private bool _Authenticated = false;
    private string _GridUri = string.Empty;

    public string Token {
        get { return _Token; }
        set { this._Token = value; }
    }

    public DateTime Timestamp {
        get { return _Timestamp; }
        set { this._Timestamp = value; }
    }

    public System.Management.Automation.PSCredential Credential {
        get { return _Credential; }
        set { this._Credential = value;}
    }

    public bool Authenticated {
        get { return _Authenticated; }
        set { this._Authenticated = value; }
    }

    public string GridUri {
        get { return _GridUri; }
        set { this._GridUri = value; }
    }
    
    public string GridPort {
        get { 
            string exp = @"^(?<protocol>\w+)://[^/]+?:(?<port>\d+)?/";
            Regex r = new Regex(exp, RegexOptions.IgnoreCase);
            Match m = r.Match(this._GridUri);
            if(m.Success) {
                return m.Groups["port"].Value;
            } else {
                // Lets Keep this legacy split as a fallback
                return this._GridUri.Split(':')[2].Split('/')[0];
            }
        }
    }
    
    // TODO: Validate Token length from AO. This defaults to 1hr.  
    public System.DateTime TokenExpires {
        get { return this._Timestamp.AddHours(1); }
    }

    public bool TokenExpired {
        get { return (this.TokenExpires < DateTime.Now); }
    }

"@ 

unit sqlcmdcli.CommandOptions;

interface

type
  THelpOptions = class
  public
    class var CommandName: string;
  end;

  TQueryStoreWorkloadOptions = class
  public
    //class var ServerName: string;
    //class var DatabaseName: string;
    //class var UserName: string;
    //class var Password: string;
  end;

  TStressDBOptions = class
  public
    class var MeltCPU: Boolean;
  end;

  TGlobalOptions = class
  public
    class var ServerName: string;
    class var DatabaseName: string;
    class var UserName: string;
    class var Password: string;
    class var Verbose: Boolean;
  end;

implementation

end.

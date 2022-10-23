unit sqlcmdcli.CommandOptions;

interface

type
  THelpOptions = class
  public
    class var CommandName: string;
  end;

  TQueryStoreWorkloadOptions = class
  public
    class var PSP: Boolean;
  end;

  TStressDBOptions = class
  public
    class var MeltCPU: Boolean;
  end;

  TAlterColumnOptions = class
  public
    class var SchemaName: string;
    class var TableName: string;
    class var ColumnName: string;
    class var ColumnRename: string;
    class var DataType: string;
  end;

  TAnonymizeDBOptions = class
  public
    class var SchemaName: string;
    class var TableName: string;
    class var ColumnName: string;
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

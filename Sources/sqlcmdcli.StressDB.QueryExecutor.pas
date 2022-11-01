unit sqlcmdcli.StressDB.QueryExecutor;

interface

uses
  Data.Win.ADODB
  ,sqlcmdcli.SchemaExtractor;

type
  TSQLDBQueryExecutor = class(TObject)
  protected
    FConnection: TADOConnection;
    FSchema: TDBSchema;
  public
    constructor Create(AConnection: TADOConnection; ASchema: TDBSchema);
    destructor Destroy; override;
    procedure StressDB(AMeltCPU: Boolean);
  end;

implementation

uses
  System.SysUtils
  ,sqlcmdcli.Console
  ,sqlcmdcli.ResourceStrings;

{ TSQLDBQueryExecutor }

constructor TSQLDBQueryExecutor.Create(AConnection: TADOConnection; ASchema: TDBSchema);
begin
  FConnection := AConnection;
  FSchema := ASchema;
end;

destructor TSQLDBQueryExecutor.Destroy;
begin
  //FSchema.Clear;
  //FreeAndNil(FSchema);

  inherited;
end;

procedure TSQLDBQueryExecutor.StressDB(AMeltCPU: Boolean);
var
  LTableName: string;
  LQry: TADOQuery;
begin
  // Let's stress the DB!
  TConsole.Log(True, RS_CMD_STRESSDB_BEGIN, Success, True);

  LQry := TADOQuery.Create(nil);
  TADODataSet(LQry).CommandTimeOut := 300;
  try
    LQry.Connection := FConnection;

    for LTableName in FSchema.Keys do
    begin
      LQry.SQL.Text :=
        'SELECT * FROM ' + LTableName;
      TConsole.Log(True, LQry.SQL.Text, Success, False);
      LQry.Open;
      LQry.RecordCount;
      LQry.Last;
      //Sleep(2000);
      LQry.Close;
    end;
    TConsole.Log(True, RS_CMD_STRESSDB_END, Success, False);

  finally
    FreeAndNil(LQry);
  end;

end;

end.

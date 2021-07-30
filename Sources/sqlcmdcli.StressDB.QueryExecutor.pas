unit sqlcmdcli.StressDB.QueryExecutor;

interface

uses
  ADODB
  ,sqlcmdcli.StressDB.SchemaExtractor;

type

  TSQLDBQueryExecutor = class(TObject)
  protected
    FConnection: TADOConnection;
    FSchema: TDBSchema;
    FIndex: TDBSchemaIndex;
  public
    constructor Create(AConnection: TADOConnection; AIndex: TDBSchemaIndex; ASchema: TDBSchema);
    destructor Destroy; override;
    procedure StressDB(AMeltCPU: Boolean);
  end;

implementation

uses
  System.SysUtils
  ,sqlcmdcli.Console
  ,sqlcmdcli.ResourceStrings;

{ TSQLDBQueryExecutor }

constructor TSQLDBQueryExecutor.Create(AConnection: TADOConnection;
  AIndex: TDBSchemaIndex; ASchema: TDBSchema);
begin
  FConnection := AConnection;
  FIndex := AIndex;
  FSchema := ASchema;
end;

destructor TSQLDBQueryExecutor.Destroy;
begin
  //FIndex.Clear;
  //FreeAndNil(FIndex);
  //FSchema.Clear;
  //FreeAndNil(FSchema);

  inherited;
end;

procedure TSQLDBQueryExecutor.StressDB(AMeltCPU: Boolean);
var
  LIndex: Integer;
  //LTableName: string;
  LQry: TADOQuery;
begin
  // Let's stress the DB!
  TConsole.Log(RS_CMD_STRESSDB_BEGIN, Success, True);

  LQry := TADOQuery.Create(nil);
  TADODataSet(LQry).CommandTimeOut := 300;
  try
    LQry.Connection := FConnection;

    //while (FIndex.Count > 0) do
    //begin
    //  LIndex := Random(FSchema.Count);
    //
    //  if (FIndex.TryGetValue(LIndex, LTableName)) then
    //  begin
    //    LQry.SQL.Text := 'SELECT * FROM ' + LTableName;
    //    LQry.Open;
    //    LQry.Close;
    //    FIndex.Remove(LIndex);
    //  end;
    //end;

    //for LIndex := 0 to (FSchema.Count - 1) do
    for LIndex := 0 to (FIndex.Count - 1) do
    begin
      LQry.SQL.Text := 'SELECT * FROM ' + FIndex.Items[LIndex];
      TConsole.Log(LQry.SQL.Text, Success, False);
      LQry.Open;
      LQry.RecordCount;
      LQry.Last;
      //Sleep(2000);
      LQry.Close;
    end;
    TConsole.Log(RS_CMD_STRESSDB_END, Success, False);

  finally
    FreeAndNil(LQry);
  end;

end;

end.

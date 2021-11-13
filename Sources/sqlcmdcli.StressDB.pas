unit sqlcmdcli.StressDB;

interface

type
  TStressDB = class(TObject)
  public
    class procedure Run(const AServerName, ADatabaseName, AUserName, APassword: string;
      AVerbose, AMeltCPU: Boolean);
  end;

implementation

uses
  Winapi.ActiveX
  ,Data.Win.ADODB
  ,System.SysUtils
  ,sqlcmdcli.SchemaExtractor
  ,sqlcmdcli.StressDB.QueryExecutor
  ,sqlcmdcli.Console
  ,sqlcmdcli.ResourceStrings;

{ TStressDB }

class procedure TStressDB.Run(const AServerName, ADatabaseName, AUserName,
  APassword: string; AVerbose, AMeltCPU: Boolean);
var
  LConnection: TADOConnection;
  LDBSchema: TDBSchema;
  LDBSchemaExtractor: TSQLDBSchemaExtractor;
  LQueryExecutor: TSQLDBQueryExecutor;
begin
  CoInitialize(nil);

  try
    // Create
    LConnection := TADOConnection.Create(nil);
    LDBSchema := TDBSchema.Create;
    //LDBIndex := TDBSchemaIndex.Create;

    try
      // ADO connection string
      LConnection.ConnectionString :=
        'Provider=SQLNCLI11;' +
        //'Integrated Security="";' +
        'Persist Security Info=False;' +
        //'User ID=' + AUserName + '@' + AServerName + ';' +
        'User ID=' + AUserName + ';' +
        'Password=' + APassword + ';' +
        'Initial Catalog=' + ADatabaseName + ';' +
        'Data Source=' + AServerName + ';' +
        'Initial File Name="";' +
        'Server SPN=""';
      LConnection.Connected := True;
      if (AVerbose) then
        TConsole.Log(Format(RS_CONNECTION_SUCCESSFULLY, [AServerName]), Success, True);

      // Create Class
      LDBSchemaExtractor := TSQLDBSchemaExtractor.Create(LConnection);

      // Perform extract schema
      LDBSchemaExtractor.ExtractSchema(stFull);
      LDBSchema := LDBSchemaExtractor.DBSchema;
      //LDBIndex := LDBSchemaExtractor.DBSchemaIndex;

      LQueryExecutor := TSQLDBQueryExecutor.Create(LConnection, LDBSchema);
      LQueryExecutor.StressDB(AMeltCPU);  // ToDo: MeltCPU option is not available now!

    finally
      FreeAndNil(LDBSchema); // ToDo: To Fix
      LConnection.Close;
      FreeAndNil(LConnection);
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;

end.

unit sqlcmdcli.AnonymizeDB;

interface

type
  TAnonymizeDB = class(TObject)
  private

  public
    class procedure Run(const AServerName, ADatabaseName, AUserName, APassword: string;
      const AVerbose: Boolean);
  end;

implementation

uses
  Winapi.ActiveX
  ,Data.Win.ADODB
  ,System.SysUtils
  ,System.Generics.Collections
  ,sqlcmdcli.SchemaExtractor
  ,sqlcmdcli.Console
  ,sqlcmdcli.ResourceStrings
  ,sqlcmdcli.Utils;

{ TAnonymizeDB }

class procedure TAnonymizeDB.Run(const AServerName, ADatabaseName, AUserName,
  APassword: string; const AVerbose: Boolean);
var
  LConnection: TADOConnection;
  LDBSchema: TDBSchema;
  LDBSchemaExtractor: TSQLDBSchemaExtractor;
  LQry: TADOQuery;
  LTableName: string;
  LFKName: string;
  LIndexInfo: Integer;
  LListSQLDBTableInfo: TObjectList<TSQLDBTableInfo>;
  LSQLDBTableInfo: TSQLDBTableInfo;
  LFK: TDictionary<string, string>;

begin
  CoInitialize(nil);

  try
    // Create
    LConnection := TADOConnection.Create(nil);
    LQry := TADOQuery.Create(nil);

    try
      // ADO connection string
      LConnection.ConnectionString :=
        'Provider=SQLNCLI10.1;' +
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
      if (AVerbose) then
        TConsole.Log(Format('Extract schema for %s ...', [ADatabaseName]), Success, False);

      LDBSchemaExtractor.ExtractSchema(stText);
      LDBSchema := LDBSchemaExtractor.DBSchema;
      //LDBSchemaIndex := LDBSchemaExtractor.DBSchemaIndex;
      if (AVerbose) then
        TConsole.Log('Done!', Success, True);

      // Anonymization logic

      //LQueryExecutor := TSQLDBQueryExecutor.Create(LConnection, LDBIndex, LDBSchema);
      //LQueryExecutor.Anonymize;

      // Let's anonymize data!
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_BEGIN, [ADatabaseName]), Success, True);

      TADODataSet(LQry).CommandTimeOut := 300;

      LConnection.BeginTrans;
      LQry.Connection := LConnection;

      LFK := TDBUtils.GetForeignKeyOnTextColumns(LConnection);

      // Disable FK constraint
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_FK_START, [ADatabaseName]), Success, True);
      for LFKName in LFK.Keys do
      begin
        LFK.TryGetValue(LFKName, LTableName);
        LQry.SQL.Text :=
          'ALTER TABLE ' + LTableName + ' NOCHECK CONSTRAINT ' + LFKName;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_FK_END, Success, True);

      for LTableName in LDBSchema.Keys do
      begin
        if LDBSchema.TryGetValue(LTableName, LListSQLDBTableInfo) then
          //TConsole.Log(LTableName + ': ', Success, False);
          ;

        for LIndexInfo := 0 to (LListSQLDBTableInfo.Count - 1) do
        begin
          LSQLDBTableInfo := LListSQLDBTableInfo.Items[LIndexInfo];
          if (LSQLDBTableInfo.DataType = '[char]') or
             (LSQLDBTableInfo.DataType = '[nchar]') or
             (LSQLDBTableInfo.DataType = '[varchar]') or
             (LSQLDBTableInfo.DataType = '[nvarchar]') or
             (LSQLDBTableInfo.DataType = '[text]') or
             (LSQLDBTableInfo.DataType = '[ntext]') then
          begin
            LQry.SQL.Text := 'UPDATE ' + LSQLDBTableInfo.TableSchema + '.' + LSQLDBTableInfo.TableName + ' ' +
                             'SET '+ LSQLDBTableInfo.ColumnName + ' = REVERSE(' + LSQLDBTableInfo.ColumnName + ')';
            //TConsole.Log(LQry.SQL.Text, Success, True);
            LQry.ExecSQL;
          end;
        end

      end;

      LQry.Close;

      // Enable FK constraint
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_FK_START, [ADatabaseName]), Success, True);
      for LFKName in LFK.Keys do
      begin
        LFK.TryGetValue(LFKName, LTableName);
        LQry.SQL.Text :=
          'ALTER TABLE ' + LTableName + ' CHECK CONSTRAINT ' + LFKName;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_FK_END, Success, True);

      LConnection.CommitTrans;
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_END, [ADatabaseName]), Success, False);

    finally
      FreeAndNil(LDBSchema); // ToDo: To Fix
      LQry.Close;
      LConnection.Close;
      FreeAndNil(LQry);
      FreeAndNil(LConnection);
    end;

  except
    on E: Exception do begin
      LConnection.RollbackTrans;
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;

end;

end.

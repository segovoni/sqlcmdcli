unit sqlcmdcli.AnonymizeDB;

interface

type
  TAnonymizeDB = class(TObject)
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
  LConstraintName: string;
  LSql: string;
  LIndexInfo: Integer;
  LPct: Integer;
  Li: Integer;
  LStopValue: Integer;
  LListSQLDBTableInfo: TObjectList<TSQLDBTableInfo>;
  LSQLDBTableInfo: TSQLDBTableInfo;
  LFK: TDictionary<string, string>;
  LCHK: TDictionary<string, string>;
  LTRDisable: TDictionary<string, string>;
  LTREnable: TDictionary<string, string>;
  LTableList: TDictionary<string, string>;
begin
  CoInitialize(nil);

  try
    // Create
    LConnection := TADOConnection.Create(nil);
    LQry := TADOQuery.Create(nil);
    LTableList := TDictionary<string, string>.Create;

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

      //LQueryExecutor := TSQLDBQueryExecutor.Create(LConnection, LDBIndex, LDBSchema);
      //LQueryExecutor.Anonymize;

      // Let's anonymize data!
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_BEGIN, [ADatabaseName]), Success, True);

      TADODataSet(LQry).CommandTimeOut := 300;

      LConnection.BeginTrans;
      LQry.Connection := LConnection;

      // Create anonymization functions
      TSQLUtils.SQLCharacterMaskFactory(LConnection);
      TSQLUtils.SQLStringReverseFnFactory(LConnection);
      TSQLUtils.SQLStringScramblerFnFactory(LConnection);

      // Retrive foreign key constraints on text columns
      LFK := TSQLUtils.GetForeignKeyOnTextColumns(LConnection);

      // Disable foreign key constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_FK_START, [ADatabaseName]), Success, True);
      for LConstraintName in LFK.Keys do
      begin
        LFK.TryGetValue(LConstraintName, LTableName);
        LQry.SQL.Text :=
          'ALTER TABLE ' + LTableName + ' NOCHECK CONSTRAINT ' + LConstraintName;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_FK_END, Success, True);

      // Retrive foreign key constraints on text columns
      LCHK := TSQLUtils.GetCheckConstraintOnTextColumns(LConnection);

      // Disable check constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_CHK_START, [ADatabaseName]), Success, True);
      for LConstraintName in LCHK.Keys do
      begin
        LCHK.TryGetValue(LConstraintName, LTableName);
        LQry.SQL.Text :=
          'ALTER TABLE ' + LTableName + ' NOCHECK CONSTRAINT ' + LConstraintName;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_CHK_END, Success, True);

      for LTableName in LDBSchema.Keys do
      begin
        LTableList.Add(LTableName, LTableName);
      end;

      // Retrive triggers on table with text columns
      LTRDisable := TSQLUtils.GetStateTriggerStatements(LConnection, LTableList, False);
      LTREnable := TSQLUtils.GetStateTriggerStatements(LConnection, LTableList, True);

      // Disable triggers
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_TR_START, [ADatabaseName]), Success, True);
      LQry.Close;
      for LTableName in LTRDisable.Keys do
      begin
        LTRDisable.TryGetValue(LTableName, LSql);
        LQry.SQL.Text := LSql;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_TR_END, Success, True);

      // Anonymization logic
      LStopValue := LDBSchema.Keys.Count;
      Li := 1;
      for LTableName in LDBSchema.Keys do
      begin
        LPct := Trunc(( Li * 1.0 / (LStopValue)) * 100);
        if (AVerbose) then
          TConsole.Log(Format(RS_STATUS_MSG, [Li, LStopValue, LPct]) + LTableName,
            Info, True)
        else
          TConsole.Log(Format(RS_STATUS_MSG, [Li, LStopValue, LPct]),
            Info, True);

        LDBSchema.TryGetValue(LTableName, LListSQLDBTableInfo);

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
            if ((LSQLDBTableInfo.MaxLength = 1) or
                (LSQLDBTableInfo.MaxLength = 2)) then
              Continue

            else if ((LSQLDBTableInfo.MaxLength = -1) or
                     (LSQLDBTableInfo.MaxLength > 2000)) then
              LQry.SQL.Text :=
                'UPDATE ' +
                  LSQLDBTableInfo.TableSchema + '.' + LSQLDBTableInfo.TableName + ' ' +
                'SET ' +
                  LSQLDBTableInfo.ColumnName +
                    ' = dbo.sqlcmdcli_fn_string_reverse(' + LSQLDBTableInfo.ColumnName + ')'

            else
              LQry.SQL.Text :=
                'UPDATE ' +
                  LSQLDBTableInfo.TableSchema + '.' + LSQLDBTableInfo.TableName + ' ' +
                'SET ' +
                  LSQLDBTableInfo.ColumnName +
                    ' = dbo.sqlcmdcli_fn_string_scrambler(' + LSQLDBTableInfo.ColumnName + ')';

            if (AVerbose) then
              TConsole.Log(LQry.SQL.Text, Success, True);

            LQry.ExecSQL;
          end;
        end;

        Inc(Li);
      end;

      LQry.Close;

      // Enable FK constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_FK_START, [ADatabaseName]), Success, True);
      for LConstraintName in LFK.Keys do
      begin
        LFK.TryGetValue(LConstraintName, LTableName);
        LQry.SQL.Text :=
          'ALTER TABLE ' + LTableName + ' CHECK CONSTRAINT ' + LConstraintName;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_FK_END, Success, True);

      // Enable check constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_CHK_START, [ADatabaseName]), Success, True);
      for LConstraintName in LCHK.Keys do
      begin
        LCHK.TryGetValue(LConstraintName, LTableName);
        LQry.SQL.Text :=
          'ALTER TABLE ' + LTableName + ' CHECK CONSTRAINT ' + LConstraintName;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_CHK_END, Success, True);

      // Enable triggers
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_TR_START, [ADatabaseName]), Success, True);
      LQry.Close;
      for LTableName in LTREnable.Keys do
      begin
        LTREnable.TryGetValue(LTableName, LSql);
        LQry.SQL.Text := LSql;
        LQry.ExecSQL;
      end;
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_TR_END, Success, True);

      LConnection.CommitTrans;
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_END, [ADatabaseName]), Success, False);
    finally
      FreeAndNil(LDBSchema); // ToDo: To Fix
      LQry.Close;
      LConnection.Close;
      FreeAndNil(LQry);
      FreeAndNil(LConnection);
      FreeAndNil(LTableList);
    end;

  except
    on E: Exception do begin
      LConnection.RollbackTrans;
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;

end;

end.

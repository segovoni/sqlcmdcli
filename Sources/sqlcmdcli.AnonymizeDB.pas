unit sqlcmdcli.AnonymizeDB;

interface

uses
  Data.Win.ADODB
  ,System.Generics.Collections;

type
  TAnonymizeDB = class(TObject)
  private
    class procedure EnableForeignKeyConstraints(const AConnection: TADOConnection;
      const AForeignKeyConstraints: TDictionary<string, string>);
    class procedure DisableForeignKeyConstraints(const AConnection: TADOConnection;
      const AForeignKeyConstraints: TDictionary<string, string>);
    class procedure EnableCheckConstraints(const AConnection: TADOConnection;
      const ACheckConstraints: TDictionary<string, string>);
    class procedure DisableCheckConstraints(const AConnection: TADOConnection;
      const ACheckConstraints: TDictionary<string, string>);
    class procedure EnableTriggers(const AConnection: TADOConnection;
      const ATriggers: TDictionary<string, string>);
    class procedure DisableTriggers(const AConnection: TADOConnection;
      const ATriggers: TDictionary<string, string>);
  public
    class procedure Run(const AServerName, ADatabaseName, AUserName, APassword: string;
      const AVerbose: Boolean);
  end;

implementation

uses
  Winapi.ActiveX
  ,System.SysUtils
  ,System.Math
  ,sqlcmdcli.SchemaExtractor
  ,sqlcmdcli.Console
  ,sqlcmdcli.ResourceStrings
  ,sqlcmdcli.Utils;

{ TAnonymizeDB }

class procedure TAnonymizeDB.DisableCheckConstraints(
  const AConnection: TADOConnection;
  const ACheckConstraints: TDictionary<string, string>);
var
  LQry: TADOQuery;
  LConstraintName: string;
  LTableName: string;
begin
  LQry := TADOQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    for LConstraintName in ACheckConstraints.Keys do
    begin
      ACheckConstraints.TryGetValue(LConstraintName, LTableName);
      LQry.SQL.Text :=
        'ALTER TABLE ' + LTableName + ' NOCHECK CONSTRAINT ' + LConstraintName;
      LQry.ExecSQL;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TAnonymizeDB.DisableForeignKeyConstraints(
  const AConnection: TADOConnection;
  const AForeignKeyConstraints: TDictionary<string, string>);
var
  LQry: TADOQuery;
  LConstraintName: string;
  LTableName: string;
begin
  LQry := TADOQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    for LConstraintName in AForeignKeyConstraints.Keys do
    begin
      AForeignKeyConstraints.TryGetValue(LConstraintName, LTableName);
      LQry.SQL.Text :=
        'ALTER TABLE ' + LTableName + ' NOCHECK CONSTRAINT ' + LConstraintName;
      LQry.ExecSQL;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TAnonymizeDB.DisableTriggers(const AConnection: TADOConnection;
  const ATriggers: TDictionary<string, string>);
var
  LQry: TADOQuery;
  LTableName: string;
  LSQL: string;
begin
  LQry := TADOQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    for LTableName in ATriggers.Keys do
    begin
      ATriggers.TryGetValue(LTableName, LSQL);
      LQry.SQL.Text := LSQL;
      LQry.ExecSQL;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TAnonymizeDB.EnableCheckConstraints(
  const AConnection: TADOConnection;
  const ACheckConstraints: TDictionary<string, string>);
var
  LQry: TADOQuery;
  LConstraintName: string;
  LTableName: string;
begin
  LQry := TADOQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    for LConstraintName in ACheckConstraints.Keys do
    begin
      ACheckConstraints.TryGetValue(LConstraintName, LTableName);
      LQry.SQL.Text :=
        'ALTER TABLE ' + LTableName + ' CHECK CONSTRAINT ' + LConstraintName;
      LQry.ExecSQL;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TAnonymizeDB.EnableForeignKeyConstraints(
  const AConnection: TADOConnection;
  const AForeignKeyConstraints: TDictionary<string, string>);
var
  LQry: TADOQuery;
  LConstraintName: string;
  LTableName: string;
begin
  LQry := TADOQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    for LConstraintName in AForeignKeyConstraints.Keys do
    begin
      AForeignKeyConstraints.TryGetValue(LConstraintName, LTableName);
      LQry.SQL.Text :=
        'ALTER TABLE ' + LTableName + ' CHECK CONSTRAINT ' + LConstraintName;
      LQry.ExecSQL;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TAnonymizeDB.EnableTriggers(const AConnection: TADOConnection;
  const ATriggers: TDictionary<string, string>);
var
  LQry: TADOQuery;
  LTableName: string;
  LSQL: string;
begin
  LQry := TADOQuery.Create(nil);
  LQry.Connection := AConnection;
  try
    for LTableName in ATriggers.Keys do
    begin
      ATriggers.TryGetValue(LTableName, LSQL);
      LQry.SQL.Text := LSQL;
      LQry.ExecSQL;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TAnonymizeDB.Run(const AServerName, ADatabaseName, AUserName,
  APassword: string; const AVerbose: Boolean);
var
  LConnection: TADOConnection;
  LDBSchema: TDBSchema;
  LDBSchemaExtractor: TSQLDBSchemaExtractor;
  LQry: TADOQuery;
  LTableName: string;
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

  LConnection := TADOConnection.Create(nil);
  LTableList := TDictionary<string, string>.Create;

  try  // finally
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

    try  // except
      LConnection.Connected := True;

      if (AVerbose) then
        TConsole.Log(Format(RS_CONNECTION_SUCCESSFULLY, [AServerName]), Success, True);

      LDBSchemaExtractor := TSQLDBSchemaExtractor.Create(LConnection);
      try
        // Perform extract schema
        if (AVerbose) then
          TConsole.Log(Format('Extract schema for %s ...', [ADatabaseName]), Success, False);

        LDBSchemaExtractor.ExtractSchema(stText);
        LDBSchema := LDBSchemaExtractor.DBSchema;
        //LDBSchemaIndex := LDBSchemaExtractor.DBSchemaIndex;
      finally
        FreeAndNil(LDBSchemaExtractor);
      end;

      if (AVerbose) then
        TConsole.Log('Done!', Success, True);

      // Let's anonymize data!
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_BEGIN, [ADatabaseName]), Success, True);

      LConnection.BeginTrans;

      // Create anonymization functions
      TSQLUtils.SQLCharacterMaskFactory(LConnection);
      TSQLUtils.SQLStringReverseFnFactory(LConnection);
      TSQLUtils.SQLStringScramblerFnFactory(LConnection);

      // Retrive foreign key constraints on text columns
      LFK := TSQLUtils.GetForeignKeyOnTextColumns(LConnection);

      // Disable foreign key constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_FK_START, [ADatabaseName]), Success, True);
      DisableForeignKeyConstraints(LConnection, LFK);
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_FK_END, Success, True);

      // Retrive check constraints on text columns
      LCHK := TSQLUtils.GetCheckConstraintOnTextColumns(LConnection);

      // Disable check constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_CHK_START, [ADatabaseName]), Success, True);
      DisableCheckConstraints(LConnection, LCHK);
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_CHK_END, Success, True);

      for LTableName in LDBSchema.Keys do
        LTableList.Add(LTableName, LTableName);

      // Retrive triggers on table with text columns
      LTRDisable := TSQLUtils.GetStateTriggerStatements(LConnection, LTableList, False);
      LTREnable := TSQLUtils.GetStateTriggerStatements(LConnection, LTableList, True);

      // Disable triggers
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_DISABLE_TR_START, [ADatabaseName]), Success, True);
      DisableTriggers(LConnection, LTRDisable);
      TConsole.Log(RS_CMD_ANONYMIZEDB_DISABLE_TR_END, Success, True);

      // Anonymization logic
      LStopValue := LDBSchema.Keys.Count;
      Li := 1;
      for LTableName in LDBSchema.Keys do
      begin
        LPct := Trunc((Li * 1.0 / (LStopValue)) * 100);
        if (AVerbose) then
          TConsole.Log(Format(RS_STATUS_MSG, [Li, LStopValue, LPct]) + LTableName,
            Info, True)
        else
          TConsole.Log(Format(RS_STATUS_MSG, [Li, LStopValue, LPct]),
            Info, True);

        LDBSchema.TryGetValue(LTableName, LListSQLDBTableInfo);

        LQry := TADOQuery.Create(nil);
        try
          LQry.Connection := LConnection;
          TADODataSet(LQry).CommandTimeOut := 300;

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
                      ' = dbo.sqlcmdcli_fn_string_reverse(' + LSQLDBTableInfo.ColumnName + ') ' +
                  'WHERE (' + LSQLDBTableInfo.ColumnName + ' IS NOT NULL) ' +
                    'AND (' + LSQLDBTableInfo.ColumnName + '<>'''')'

              else
                LQry.SQL.Text :=
                  'UPDATE ' +
                    LSQLDBTableInfo.TableSchema + '.' + LSQLDBTableInfo.TableName + ' ' +
                  'SET ' +
                    LSQLDBTableInfo.ColumnName +
                      ' = dbo.sqlcmdcli_fn_string_scrambler(' + LSQLDBTableInfo.ColumnName + ', ' + IntToStr(RandomRange(1, 9)) + ') ' +
                  'WHERE (' + LSQLDBTableInfo.ColumnName + ' IS NOT NULL) ' +
                    'AND (' + LSQLDBTableInfo.ColumnName + '<>'''')';

              if (AVerbose) then
                TConsole.Log(LQry.SQL.Text, Success, True);

              LQry.ExecSQL;
            end;
          end;
        finally
          FreeAndNil(LQry);
        end;

        Inc(Li);
      end;

      // Enable foreign key constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_FK_START, [ADatabaseName]), Success, True);
      EnableForeignKeyConstraints(LConnection, LFK);
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_FK_END, Success, True);

      // Enable check constraints
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_CHK_START, [ADatabaseName]), Success, True);
      EnableCheckConstraints(LConnection, LCHK);
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_CHK_END, Success, True);

      // Enable triggers
      if (AVerbose) then
        TConsole.Log(Format(RS_CMD_ANONYMIZEDB_ENABLE_TR_START, [ADatabaseName]), Success, True);
      EnableTriggers(LConnection, LTREnable);
      TConsole.Log(RS_CMD_ANONYMIZEDB_ENABLE_TR_END, Success, True);

      LConnection.CommitTrans;
      TConsole.Log(Format(RS_CMD_ANONYMIZEDB_END, [ADatabaseName]), Success, False);
    except
      on E: Exception do begin
        LConnection.RollbackTrans;
        //Writeln(E.ClassName, ': ', E.Message);
        TConsole.Log(E.ClassName + ': ' + E.Message, Error, True);
      end;
    end;

  finally
    FreeAndNil(LDBSchema); // ToDo: To Fix
    LConnection.Close;
    FreeAndNil(LConnection);
    FreeAndNil(LTableList);
  end;

end;

end.

unit sqlcmdcli.AlterColumn;

interface

type
  TAlterColumn = class(TObject)
  public
    class procedure Run(const AServerName, ADatabaseName, AUserName, APassword,
      ASchemaName, ATableName, AColumnName, AColumnRename, ADataType: string;
      const AVerbose: Boolean);
  end;

implementation

uses
  Winapi.ActiveX
  ,Data.Win.ADODB
  ,System.SysUtils
  ,System.StrUtils
  ,sqlcmdcli.Console
  ,sqlcmdcli.ResourceStrings
  ,sqlcmdcli.Utils;

{ TAlterColumn }

class procedure TAlterColumn.Run(const AServerName, ADatabaseName, AUserName,
  APassword, ASchemaName, ATableName, AColumnName, AColumnRename,
  ADataType: string; const AVerbose: Boolean);
var
  LConnection: TADOConnection;
  LQry: TADOQuery;
  LSQLAlterColumn: string;
  Li: Integer;
begin
  CoInitialize(nil);

  LConnection := TADOConnection.Create(nil);
  LQry := TADOQuery.Create(nil);

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
      LQry.Connection := LConnection;
      LQry.Prepared := False;
      LQry.ParamCheck := False;
      LConnection.BeginTrans;

      TConsole.Log(True, Format(RS_CONNECTION_SUCCESSFULLY, [AServerName]),
        Success, True);

      // Let's go!
      TConsole.Log(AVerbose, Format(RS_CMD_ALTERCOLUMN_BEGIN, [AColumnName, ATableName, ADatabaseName]),
        Success, True);

      LQry.SQL.Text :=
        'IF (OBJECT_ID(''dbo.sp_alter_column'', ''P'') IS NOT NULL) ' +
          'DROP PROCEDURE dbo.sp_alter_column';
      LQry.ExecSQL;

      LSQLAlterColumn := TResourceUtils.GetResourceString('sp_alter_column', 'TEXT');
      LQry.SQL.Text := LSQLAlterColumn;

      for Li := (LQry.SQL.Count - 1) downto 0 do
        if StartsText('GO', LQry.SQL[Li]) then
          LQry.SQL.Delete(Li);

      for Li := (LQry.SQL.Count - 1) downto 0 do
        if StartsText('IF OBJECT_ID(''dbo.sp_alter_column'', ''P'') IS NOT NULL', LQry.SQL[Li]) then
          LQry.SQL.Delete(Li);

      for Li := (LQry.SQL.Count - 1) downto 0 do
        if StartsText('  DROP PROCEDURE dbo.sp_alter_column;', LQry.SQL[Li]) then
          LQry.SQL.Delete(Li);

      LQry.ExecSQL;

      LSQLAlterColumn :=
        'EXEC dbo.sp_alter_column @schemaname = ''' + ASchemaName +
          ''', @tablename = ''' + ATableName +
          ''', @columnname = ''' + AColumnName;

      if (Trim(AColumnRename) <> '') and
         (AColumnRename <> AColumnName) then
        LSQLAlterColumn := LSQLAlterColumn +
          ''', @columnrename = ''' + AColumnRename;

      LSQLAlterColumn := LSQLAlterColumn +
        ''', @datatype = ''' + ADataType +
        ''', @executionmode = -1';

      LQry.SQL.Text := LSQLAlterColumn;
      LQry.ExecSQL;

      LQry.SQL.Text :=
        'IF (OBJECT_ID(''dbo.sp_alter_column'', ''P'') IS NOT NULL) ' +
          'DROP PROCEDURE dbo.sp_alter_column';
      LQry.ExecSQL;

      LConnection.CommitTrans;
      TConsole.Log(True, Format(RS_CMD_ALTERCOLUMN_END, [AColumnName]), Success, True);
    except
      on E: Exception do begin
        LConnection.RollbackTrans;
        TConsole.Log(True, E.ClassName + ': ' + E.Message, Error, True);
      end;
    end;

  finally
    LQry.Close;
    FreeAndNil(LQry);
    LConnection.Close;
    FreeAndNil(LConnection);
  end;

end;

end.

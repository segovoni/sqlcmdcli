unit sqlcmdcli.Utils;

interface

uses
  System.Generics.Collections,
  Data.Win.ADODB;

type

  TResourceUtils = class(TObject)
  public
    class function GetResourceString(const AResourceName, AResourceType: string): string;
  end;

  TStringUtils = class(TObject)
  public
    class function StringScrambler(const AValue: string): string;
  end;

  TSQLUtils = class(TObject)
  public
    class function GetForeignKeyOnTextColumns(AConnection: TADOConnection)
      : TDictionary<string, string>;
    class function GetCheckConstraintOnTextColumns(AConnection: TADOConnection)
      : TDictionary<string, string>;
    class function GetStateTriggerStatements(AConnection: TADOConnection;
      const ATableList: TDictionary<string, string>; const AState: Boolean)
      : TDictionary<string, string>;
    class procedure SQLCharacterMaskFactory(AConnection: TADOConnection);
    class procedure SQLStringReverseFnFactory(AConnection: TADOConnection);
    class procedure SQLStringScramblerFnFactory(AConnection: TADOConnection);
    class function CheckNativeClient(const AVersion: string): Boolean;
  end;

implementation

uses
  System.Classes
  ,System.SysUtils
  ,System.StrUtils
  ,System.Win.Registry
  ,Winapi.Windows;

{ TResourceUtils }

class function TResourceUtils.GetResourceString(const AResourceName,
  AResourceType: string): string;
var
  LStream: TResourceStream;
  LStrings: TStringList;
begin
  LStream := TResourceStream.Create(HInstance, AResourceName, PChar(AResourceType));
  try
    LStrings := TStringList.Create;
    try
      LStream.Position := 0;
      LStrings.Clear;
      LStrings.LoadFromStream(LStream);
      Result := LStrings.Text;
    finally
      LStrings.Free
    end;
  finally
    LStream.Free;
  end;
end;

{ TStringUtils }

class function TStringUtils.StringScrambler(const AValue: string): string;
begin
  // "abcd" --> "dbca"
  if (Length(AValue) > 2) then
    Result := RightStr(AValue, 1) + Copy(AValue, 2, Length(AValue)-2) + LeftStr(AValue, 1)
  else if (Length(AValue) = 2) then
    Result := ReverseString(AValue)
  else
    Result := AValue;
end;

{ TDBUtils }

class procedure TSQLUtils.SQLCharacterMaskFactory(AConnection: TADOConnection);
var
  LQry: TADOQuery;
begin
  LQry := TADOQuery.Create(nil);

  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'IF OBJECT_ID(''dbo.sqlcmdcli_fn_character_mask'', ''FN'') IS NOT NULL ' +
        'DROP FUNCTION dbo.sqlcmdcli_fn_character_mask;';
    LQry.ExecSQL;

    LQry.SQL.Text :=
      // Character_mask from:
      // https://www.red-gate.com/simple-talk/sql/database-administration/obfuscating-your-sql-server-data/
      'CREATE FUNCTION dbo.sqlcmdcli_fn_character_mask ' +
      '( ' +
        '@OrigVal NVARCHAR(MAX), ' +
        '@InPlain INT, ' +
        '@MaskChar NCHAR(1) ' +
      ') ' +
      'RETURNS NVARCHAR(MAX) ' +
      'WITH ENCRYPTION ' +
      'AS ' +
      'BEGIN ' +
        //'-- Variables used ' +
        'DECLARE @PlainVal NVARCHAR(MAX); ' +
        'DECLARE @MaskVal NVARCHAR(MAX); ' +
        'DECLARE @MaskLen INT; ' +

        //'-- Captures the portion of @OrigVal that remains in plain text ' +
        'SET @PlainVal = RIGHT(@OrigVal,@InPlain); ' +
        //'-- Defines the length of the repeating value for the mask ' +
        'SET @MaskLen = (LEN(@OrigVal) - @InPlain); ' +
        //'-- Captures the mask value ' +
        'SET @MaskVal = REPLICATE(@MaskChar, @MaskLen); ' +
        //'-- Returns the masked value ' +
        'Return @MaskVal + @PlainVal ' +
      'END';
    LQry.ExecSQL;

  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TSQLUtils.SQLStringScramblerFnFactory(
  AConnection: TADOConnection);
var
  LQry: TADOQuery;
begin
  LQry := TADOQuery.Create(nil);

  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'IF OBJECT_ID(''dbo.sqlcmdcli_fn_string_scrambler'', ''FN'') IS NOT NULL ' +
        'DROP FUNCTION dbo.sqlcmdcli_fn_string_scrambler;';
    LQry.ExecSQL;

    LQry.SQL.Text :=
      'CREATE FUNCTION dbo.sqlcmdcli_fn_string_scrambler ' +
      '(' +
      '  @AValue AS NVARCHAR(MAX) ' +
      '  ,@AShift AS INTEGER ' +
      ') ' +
      'RETURNS NVARCHAR(MAX) ' +
      'AS BEGIN ' +
      '  DECLARE @LEN AS INTEGER; ' +
      '  DECLARE @I AS INTEGER; ' +
      '  DECLARE @RES AS NVARCHAR(MAX) ' +
      ' ' +
      '  SET @RES = ''''; ' +
      '  SET @LEN = LEN(@AValue); ' +
      '  SET @I = 1; ' +
      ' ' +
      '  WHILE @I <= @LEN ' +
      '  BEGIN ' +
      '    SET @RES = @RES + NCHAR(UNICODE(SUBSTRING(@AValue, @I, 1)) + @AShift); ' +
      '  SET @I = @I + 1; ' +
      '  END; ' +
      '  RETURN @RES; ' +
      'END;';
    LQry.ExecSQL;

  finally
    FreeAndNil(LQry);
  end;
end;

class procedure TSQLUtils.SQLStringReverseFnFactory(
  AConnection: TADOConnection);
var
  LQry: TADOQuery;
begin
  LQry := TADOQuery.Create(nil);

  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'IF OBJECT_ID(''dbo.sqlcmdcli_fn_string_reverse'', ''FN'') IS NOT NULL ' +
        'DROP FUNCTION dbo.sqlcmdcli_fn_string_reverse;';
    LQry.ExecSQL;

    LQry.SQL.Text :=
      'CREATE FUNCTION dbo.sqlcmdcli_fn_string_reverse ' +
      '( ' +
      '  @AValue NVARCHAR(MAX) ' +
      ') ' +
      'RETURNS NVARCHAR(MAX) ' +
      'WITH ENCRYPTION ' +
      'AS ' +
      'BEGIN ' +
      '  DECLARE @Res NVARCHAR(MAX) = ''''; ' +

      //'  -- "abcd" --> "dbca"
      '  IF (LEN(@AValue) > 2) ' +
      //'    SET @Res = RIGHT(@AValue, 1) + SUBSTRING(@AValue, 2, LEN(@AValue)-2) + LEFT(@AValue, 1) ' +
      //'    SET @Res = RIGHT(@AValue, 1) + REVERSE(SUBSTRING(@AValue, 2, LEN(@AValue)-2)) + LEFT(@AValue, 1) ' +
      '    SET @Res = REVERSE(@AValue) ' +
      '  ELSE IF (LEN(@AValue) = 2) ' +
      '    SET @Res = LTRIM(RTRIM(REVERSE(@AValue))) ' +
      '  ELSE ' +
      '    SET @Res = @AValue ' +
      '  RETURN @Res ' +
      'END';
    LQry.ExecSQL;

  finally
    FreeAndNil(LQry);
  end;
end;

class function TSQLUtils.GetStateTriggerStatements(AConnection: TADOConnection;
  const ATableList: TDictionary<string, string>; const AState: Boolean)
  : TDictionary<string, string>;
var
  LQry: TADOQuery;
  LSql: string;
  LTableName: string;
  LTableList: string;
begin
  Result := TDictionary<string, string>.Create;
  LQry := TADOQuery.Create(nil);
  try
    LQry.Connection := AConnection;

    for LTableName in ATableList.Keys do
    begin
      LTableList := LTableList + LTableName + ', ';
    end;

    LSql :=
      'SELECT ' +
        'TRIGGER_NAME = tr.name ' +
        ',T.TABLE_SCHEMA ' +
        ',T.TABLE_NAME ' +
        ',FullTableName = ''['' + RTRIM(T.TABLE_SCHEMA) + ''].['' + RTRIM(T.TABLE_NAME) + '']''';

    if (AState) then
      LSql :=
        LSql +
        ',''E'' AS OperationType ' +  // E = Enable
        ',(' +
        '''ALTER TABLE ['' + RTRIM(T.TABLE_SCHEMA) + ''].['' + RTRIM(T.TABLE_NAME) + ''] '' + ' +
        '''ENABLE TRIGGER ['' + RTRIM(tr.name) + ''];''' +
        ' ) AS SQLStr '
    else
      LSql :=
        LSql +
        ',''I'' AS OperationType ' + // I = Disable
        ',(' +
        '''ALTER TABLE ['' + RTRIM(T.TABLE_SCHEMA) + ''].['' + RTRIM(T.TABLE_NAME) + ''] '' + ' +
        '''DISABLE TRIGGER ['' + RTRIM(tr.name) + ''];''' +
        ' ) AS SQLStr ';

    LSql :=
      LSql +
      'FROM ' +
        'sys.triggers AS tr ' +
      'JOIN ' +
        'sys.objects AS o ON o.[object_id]=tr.[parent_id] ' +
      'JOIN ' +
        'sys.schemas AS s ON o.[schema_id]=s.[schema_id] ' +
      'JOIN ' +
        'INFORMATION_SCHEMA.TABLES AS T ' +
        'ON (T.TABLE_SCHEMA=s.name) ' +
           'AND (T.TABLE_NAME=o.name) ' +
      'WHERE ' +
        'EXISTS (SELECT ' +
                  'C.COLUMN_NAME ' +
                'FROM ' +
                  'INFORMATION_SCHEMA.COLUMNS AS C ' +
                'WHERE ' +
                  '(T.TABLE_CATALOG=C.TABLE_CATALOG) ' +
                  'AND (T.TABLE_SCHEMA=C.TABLE_SCHEMA) ' +
                  'AND (T.TABLE_NAME=C.TABLE_NAME) ' +
                  'AND (C.DATA_TYPE IN (''char'', ''varchar'', ''text'')) ' +
               ') ' +
        // Only enabled triggers
        'AND (tr.is_disabled = 0) ' +
        // Current database
        'AND (T.TABLE_CATALOG=DB_NAME()) ' +
        // Table list
        'AND (CHARINDEX(('',['' + LTRIM(RTRIM(T.TABLE_SCHEMA + ''].['' + T.TABLE_NAME)) + ''],''), ' +
                       '('','' + REPLACE(''' + LTableList + ''', '' '', '''') + '','')) > 0) ' +
        // ToDo: Trigger on indexed views
        'AND (T.TABLE_TYPE=''BASE TABLE'')';

    LQry.SQL.Text := LSql;
    LQry.Open;

    while (not LQry.Eof) do
    begin
      Result.Add(LQry.FieldByName('TRIGGER_NAME').AsString,
                 LQry.FieldByName('SQLStr').AsString);
      LQry.Next;
    end;
    LQry.Close;

  finally
    FreeAndNil(LQry);
  end;
end;

class function TSQLUtils.CheckNativeClient(const AVersion: string): Boolean;
var
  LRegistry: TRegistry;
begin
  Result := False;
  LRegistry := TRegistry.Create(KEY_READ);
  try
    LRegistry.RootKey := HKEY_LOCAL_MACHINE;
    // SOFTWARE\Microsoft\Microsoft SQL Server\SQLNCLI11\CurrentVersion
    if (LRegistry.KeyExists('\SOFTWARE\Microsoft\Microsoft SQL Server\' + AVersion {SQLNCLI11} + '\CurrentVersion\')) then
      Result := True;
  finally
    FreeAndNil(LRegistry);
  end;
end;

class function TSQLUtils.GetCheckConstraintOnTextColumns(
  AConnection: TADOConnection): TDictionary<string, string>;
var
  LQry: TADOQuery;
begin
  LQry := TADOQuery.Create(nil);
  Result := TDictionary<string, string>.Create;

  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'SELECT ' +
        'check_constraint_name = con.[name] ' +
        ',table_name = ''['' + SCHEMA_NAME(t.schema_id) + ''].['' + t.[name] + '']''' +
        ',column_name = ''['' + col.[name] + '']''' +
        ',con.[definition] ' +
      'FROM ' +
        'sys.check_constraints AS con ' +
      'LEFT OUTER JOIN ' +
        'sys.objects AS t ON con.parent_object_id = t.object_id ' +
      'LEFT OUTER JOIN ' +
        'sys.columns AS col ON con.parent_column_id = col.column_id ' +
          'AND con.parent_object_id = col.object_id ' +
      'WHERE ' +
        '(TYPE_NAME(col.system_type_id) IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''text'', ''ntext'')) ' +
        'AND (con.is_disabled = 0) ' +
      'ORDER BY ' +
        'con.name';
    LQry.Open;

    while not(LQry.Eof) do
    begin
      Result.Add(LQry.FieldByName('check_constraint_name').AsString,
        LQry.FieldByName('table_name').AsString);
      LQry.Next;
    end;
    LQry.Close;

  finally
    FreeAndNil(LQry);
  end;
end;

class function TSQLUtils.GetForeignKeyOnTextColumns(
  AConnection: TADOConnection): TDictionary<string, string>;
var
  LQry: TADOQuery;
begin
  LQry := TADOQuery.Create(nil);
  Result := TDictionary<string, string>.Create;

  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'SELECT ' +
        'SCHEMA_NAME(fk_tab.schema_id) + ''.'' + fk_tab.name AS foreign_table, ' +
        //'>-' as rel,
        //SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name AS primary_table,
        //fk_cols.constraint_column_id AS no,
        'fk_col.name AS fk_column_name, ' +
        //' = ' as [join],
        'pk_col.name as pk_column_name, ' +
        'fk.name as fk_constraint_name ' +
      'FROM ' +
        'sys.foreign_keys fk ' +
      'INNER JOIN ' +
        'sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id ' +
      'INNER JOIN ' +
        'sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id ' +
      'INNER JOIN ' +
        'sys.foreign_key_columns fk_cols ON fk_cols.constraint_object_id = fk.object_id ' +
      'INNER JOIN ' +
        'sys.columns fk_col ON fk_col.column_id = fk_cols.parent_column_id AND fk_col.object_id = fk_tab.object_id ' +
      'INNER JOIN ' +
        'sys.columns pk_col ON pk_col.column_id = fk_cols.referenced_column_id AND pk_col.object_id = pk_tab.object_id ' +
      'WHERE ' +
        '(TYPE_NAME(fk_col.system_type_id) IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''text'', ''ntext'')) ' +
        'AND (fk.is_disabled = 0)';
    LQry.Open;

    while not (LQry.Eof) do
    begin
      Result.Add(LQry.FieldByName('fk_constraint_name').AsString, LQry.FieldByName('foreign_table').AsString);
      LQry.Next;
    end;
    LQry.Close;

  finally
    FreeAndNil(LQry);
  end;
end;

end.

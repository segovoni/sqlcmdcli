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

  TDBUtils = class(TObject)
  public
    class function GetForeignKeyOnTextColumns(AConnection: TADOConnection): TDictionary<string, string>;
  end;

implementation

uses
  System.Classes
  ,System.SysUtils
  ,System.StrUtils;

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

class function TDBUtils.GetForeignKeyOnTextColumns(
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
      LQry.Next
    end;
    LQry.Close;

  finally
    FreeAndNil(LQry);
  end;

end;

end.

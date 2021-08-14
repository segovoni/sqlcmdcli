unit sqlcmdcli.SchemaExtractor;

interface

uses
  ADODB
  ,System.Generics.Collections;

type
  TSQLDBTableInfo = record
    //FTableCatalog: string;
    TableSchema: string;
    TableName: string;
    ColumnName: string;
    DataType: string;
    ColumnIdentity: Boolean;
    Rows: Integer;
  end;

  TDBSchema = TDictionary<string, TList<TSQLDBTableInfo>>;
  TDBSchemaIndex = TDictionary<Integer, string>;

  TSQLObjectNameFormatter = class
  public
    class function Format(AObjectName: string): string;
  end;

  TSQLDBSchemaExtractor = class(TObject)
  private
    function GetDBSchema: TDBSchema;
    function GetDBSchemaIndex: TDBSchemaIndex;
  protected
    FConnection: TADOConnection;
    FDBSchema: TDBSchema;
    FDBSchemaIndex: TDBSchemaIndex;
  public
    constructor Create(AConnection: TADOConnection);
    destructor Destroy; override;
    procedure ExtractSchema;
    property DBSchema: TDBSchema read GetDBSchema;
    property DBSchemaIndex: TDBSchemaIndex read GetDBSchemaIndex;
  end;

implementation

uses
  System.SysUtils
  ,sqlcmdcli.Console;

{ TDBSchemaExtractor }

constructor TSQLDBSchemaExtractor.Create(AConnection: TADOConnection);
begin
  FConnection := AConnection;
  FDBSchema := TDBSchema.Create;
  FDBSchemaIndex := TDBSchemaIndex.Create;
end;

destructor TSQLDBSchemaExtractor.Destroy;
begin
  //FDBSchema.Clear;
  //FreeAndNil(FDBSchema);
  //FDBSchemaIndex.Clear;
  //FreeAndNil(FDBSchemaIndex);

  inherited;
end;

procedure TSQLDBSchemaExtractor.ExtractSchema;
var
  LQry: TADOQuery;
  LColumn: TSQLDBTableInfo;
  LCurrentTable: string;
  LList: TList<TSQLDBTableInfo>;
  LIndex: Integer;
begin
  // Logica di estrazione dello schema DB

  LQry := TADOQuery.Create(nil);
  LList := TList<TSQLDBTableInfo>.Create;
  LIndex := 0;
  try
    LQry.Connection := FConnection;
    LQry.SQL.Text :=
      'SELECT ' +
        'TABLE_SCHEMA = SCHEMA_NAME(T.schema_id) ' +
        ',TABLE_NAME = T.name ' +
        ',ORDINAL_POSITION = C.column_id ' +
        ',COLUMN_NAME = C.name ' +
        ',DATA_TYPE = TYPE_NAME(C.system_type_id) ' +
        ',COLUMN_IDENTITY = C.is_identity ' +
        ',ROWS = P.rows ' +
      'FROM ' +
        'sys.tables AS T ' +
      'JOIN ' +
        'sys.columns AS C ON T.object_id=C.object_id ' +
      'JOIN ' +
        'sys.partitions AS P on P.object_id=T.object_id ' +
      'WHERE ' +
        '(T.type = ''U'') ' +
        'AND (T.is_memory_optimized = 0) ' +
        'AND (T.is_ms_shipped = 0) ' +
      'ORDER BY ' +
        'TABLE_SCHEMA ' +
        ',TABLE_NAME ' +
        ',COLUMN_NAME ' +
        ',ORDINAL_POSITION';
    LQry.Open;

    //
    if not (LQry.Eof) then
      LCurrentTable :=
        TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
        '.' +
        TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);

    while (not LQry.Eof) do
    begin
      //LColumn.TableCatalog := TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_CATALOG').AsString);
      LColumn.TableSchema := TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString);
      LColumn.TableName := TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);
      LColumn.ColumnName := TSQLObjectNameFormatter.Format(LQry.FieldByName('COLUMN_NAME').AsString);
      LColumn.DataType := TSQLObjectNameFormatter.Format(LQry.FieldByName('DATA_TYPE').AsString);
      LColumn.ColumnIdentity := LQry.FieldByName('COLUMN_IDENTITY').AsBoolean;
      LColumn.Rows := LQry.FieldByName('ROWS').AsInteger;

      if (CompareText(LCurrentTable, LColumn.TableSchema + '.' + LColumn.TableName) = 0) then
        LList.Add(LColumn)
      else begin
        TConsole.Log('Add ' + LCurrentTable, Info, True);
        FDBSchema.Add(LCurrentTable, LList);
        FDBSchemaIndex.Add(LIndex, LCurrentTable);
        Inc(LIndex);
        LList.Clear;
        LList.Add(LColumn);
        LCurrentTable :=
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
          '.' +
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);
      end;

      LQry.Next;
    end;

    FDBSchema.Add(LColumn.TableSchema + '.' + LColumn.TableName, LList);

  finally
    FreeAndNil(LQry);
    FreeAndNil(LList);
  end;
end;

function TSQLDBSchemaExtractor.GetDBSchema: TDictionary<string, TList<TSQLDBTableInfo>>;
begin
  Result := FDBSchema;
end;

function TSQLDBSchemaExtractor.GetDBSchemaIndex: TDBSchemaIndex;
begin
  Result := FDBSchemaIndex;
end;

{ TSQLObjectNameFormatter }

class function TSQLObjectNameFormatter.Format(
  AObjectName: string): string;
begin
  Result := '[' + AObjectName + ']';
end;

end.

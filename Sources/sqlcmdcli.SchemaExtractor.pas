unit sqlcmdcli.SchemaExtractor;

interface

uses
  System.Generics.Collections
  ,Data.Win.ADODB;

type
  TSchemaType = (stFull, stText);

  TSQLDBTableInfo = class(TObject)
  protected
    FTableSchema: string;
    FTableName: string;
    FColumnName: string;
    FDataType: string;
    FMaxLength: Integer;
    FColumnIdentity: Boolean;
  public
    constructor Create(const ATableSchema, ATableName, AColumnName, ADataType: string;
      const AMaxLength: Integer; const AColumnIdentity: Boolean);
    property TableSchema: string read FTableSchema;
    property TableName: string read FTableName;
    property ColumnName: string read FColumnName;
    property DataType: string read FDataType;
    property MaxLength: Integer read FMaxLength;
    property ColumnIdentity: Boolean read FColumnIdentity;
  end;

  //TDBSchemaIndex = TDictionary<Integer, string>;
  TDBSchema = TDictionary<string, TObjectList<TSQLDBTableInfo>>;

  TSQLObjectNameFormatter = class
  public
    class function Format(AObjectName: string): string;
  end;

  TSQLDBSchemaExtractor = class(TObject)
  private
    function GetDBSchema: TDBSchema;
    //function GetDBSchemaIndex: TDBSchemaIndex;
    function GetSQLbySchemaType(ASchemaType: TSchemaType): string;
    function GetSQLbySchema(const ASchemaName, ATableName, AColumnName: string): string;
  protected
    FConnection: TADOConnection;
    FDBSchema: TDBSchema;
    //FDBSchemaIndex: TDBSchemaIndex;
  public
    constructor Create(AConnection: TADOConnection);
    destructor Destroy; override;
    procedure ExtractSchema(ASchemaType: TSchemaType); overload;
    procedure ExtractSchema(const ASchemaName, ATableName, AColumnName: string); overload;
    property DBSchema: TDBSchema read GetDBSchema;
    //property DBSchemaIndex: TDBSchemaIndex read GetDBSchemaIndex;
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
  //FDBSchemaIndex := TDBSchemaIndex.Create;
end;

destructor TSQLDBSchemaExtractor.Destroy;
begin
  //FDBSchema.Clear;
  //FreeAndNil(FDBSchema);
  //FDBSchemaIndex.Clear;
  //FreeAndNil(FDBSchemaIndex);

  inherited;
end;

procedure TSQLDBSchemaExtractor.ExtractSchema(const ASchemaName, ATableName,
  AColumnName: string);
var
  LQry: TADOQuery;
  LCurrentTable: string;
  LList: TObjectList<TSQLDBTableInfo>;
begin
  // Database schema extractor logic

  LQry := TADOQuery.Create(nil);
  LList := TObjectList<TSQLDBTableInfo>.Create();
  try
    LQry.Connection := FConnection;
    LQry.SQL.Text := GetSQLbySchema(ASchemaName, ATableName, AColumnName);
    LQry.Open;

    //
    if not (LQry.Eof) then
      LCurrentTable :=
        TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
        '.' +
        TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);

    while (not LQry.Eof) do
    begin
      if CompareText(LCurrentTable,
                     TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) + '.' +
                     TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString)) = 0 then
      begin
        LList.Add(TSQLDBTableInfo.Create(
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString),
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString),
          TSQLObjectNameFormatter.Format(LQry.FieldByName('COLUMN_NAME').AsString),
          TSQLObjectNameFormatter.Format(LQry.FieldByName('DATA_TYPE').AsString),
          LQry.FieldByName('MAX_LENGHT').AsInteger,
          LQry.FieldByName('COLUMN_IDENTITY').AsBoolean
                                         )
                 )
      end
      else begin
        FDBSchema.Add(LCurrentTable, LList);
        LList := TObjectList<TSQLDBTableInfo>.Create();
        LList.Add(TSQLDBTableInfo.Create(
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString),
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString),
          TSQLObjectNameFormatter.Format(LQry.FieldByName('COLUMN_NAME').AsString),
          TSQLObjectNameFormatter.Format(LQry.FieldByName('DATA_TYPE').AsString),
          LQry.FieldByName('MAX_LENGHT').AsInteger,
          LQry.FieldByName('COLUMN_IDENTITY').AsBoolean
                                         )
                 );
        LCurrentTable :=
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
          '.' +
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);
      end;

      LQry.Next;
    end;

    FDBSchema.Add(TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
                                                 '.' +
                                                 TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString), LList);

  finally
    FreeAndNil(LQry);
  end;
end;

procedure TSQLDBSchemaExtractor.ExtractSchema(ASchemaType: TSchemaType);
var
  LQry: TADOQuery;
  //LColumn: TSQLDBTableInfo;
  LCurrentTable: string;
  LList: TObjectList<TSQLDBTableInfo>;
  //LIndex: Integer;
begin
  // Database schema extractor logic

  LQry := TADOQuery.Create(nil);
  LList := TObjectList<TSQLDBTableInfo>.Create();
  //LColumn := TSQLDBTableInfo.Create();
  //LIndex := 0;
  try
    LQry.Connection := FConnection;
    LQry.SQL.Text := GetSQLbySchemaType(ASchemaType);
    LQry.Open;

    //
    if not (LQry.Eof) then
      LCurrentTable :=
        TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
        '.' +
        TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);

    while (not LQry.Eof) do
    begin
      ////LColumn.TableCatalog := TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_CATALOG').AsString);
      //LColumn.TableSchema := TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString);
      //LColumn.TableName := TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);
      //LColumn.ColumnName := TSQLObjectNameFormatter.Format(LQry.FieldByName('COLUMN_NAME').AsString);
      //LColumn.DataType := TSQLObjectNameFormatter.Format(LQry.FieldByName('DATA_TYPE').AsString);
      //LColumn.ColumnIdentity := LQry.FieldByName('COLUMN_IDENTITY').AsBoolean;
      //LColumn.Rows := LQry.FieldByName('ROWS').AsInteger;

      //if (CompareText(LCurrentTable, LColumn.TableSchema + '.' + LColumn.TableName) = 0) then
      if CompareText(LCurrentTable,
                      TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) + '.' +
                      TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString)) = 0 then
        LList.Add(TSQLDBTableInfo.Create(TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString),
                                         TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString),
                                         TSQLObjectNameFormatter.Format(LQry.FieldByName('COLUMN_NAME').AsString),
                                         TSQLObjectNameFormatter.Format(LQry.FieldByName('DATA_TYPE').AsString),
                                         LQry.FieldByName('MAX_LENGHT').AsInteger,
                                         LQry.FieldByName('COLUMN_IDENTITY').AsBoolean
                                         ))
      else begin
        FDBSchema.Add(LCurrentTable, LList);
        //TConsole.Log('Schema saved for ' + LCurrentTable, Info, True);

        //FDBSchemaIndex.Add(LIndex, LCurrentTable);
        //Inc(LIndex);

        //for Li := 0 to LList.Count - 1 do
        //begin
          //FreeAndNil(LList);
          LList := TObjectList<TSQLDBTableInfo>.Create();
        //end;

        //LList.Add(LColumn);
        LList.Add(TSQLDBTableInfo.Create(TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString),
                                         TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString),
                                         TSQLObjectNameFormatter.Format(LQry.FieldByName('COLUMN_NAME').AsString),
                                         TSQLObjectNameFormatter.Format(LQry.FieldByName('DATA_TYPE').AsString),
                                         LQry.FieldByName('MAX_LENGHT').AsInteger,
                                         LQry.FieldByName('COLUMN_IDENTITY').AsBoolean
                                         ));
        LCurrentTable :=
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) +
          '.' +
          TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString);
      end;

      LQry.Next;
    end;

    //FDBSchema.Add(LColumn.TableSchema + '.' + LColumn.TableName, LList);
    FDBSchema.Add(TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_SCHEMA').AsString) + '.' + TSQLObjectNameFormatter.Format(LQry.FieldByName('TABLE_NAME').AsString), LList);

  finally
    FreeAndNil(LQry);
    //FreeAndNil(LList);
  end;
end;

function TSQLDBSchemaExtractor.GetDBSchema: TDictionary<string, TOBjectList<TSQLDBTableInfo>>;
begin
  Result := FDBSchema;
end;

function TSQLDBSchemaExtractor.GetSQLbySchema(const ASchemaName, ATableName,
  AColumnName: string): string;
begin
  Result :=
    'SELECT ' +
      'TABLE_SCHEMA = SCHEMA_NAME(T.schema_id) ' +
      ',TABLE_NAME = T.name ' +
      ',ORDINAL_POSITION = C.column_id ' +
      ',COLUMN_NAME = C.name ' +
      ',MAX_LENGHT = C.max_length ' +
      ',DATA_TYPE = TYPE_NAME(C.system_type_id) ' +
      ',COLUMN_IDENTITY = C.is_identity ' +
      //',ROWS = P.rows ' +
    'FROM ' +
      'sys.tables AS T ' +
    'JOIN ' +
      'sys.columns AS C ON T.object_id=C.object_id ' +
    //'JOIN ' +
    //  'sys.partitions AS P on P.object_id=T.object_id ' +
    'WHERE ' +
      '(T.type = ''U'') ' +
      //'AND (T.is_memory_optimized = 0) ' +
      'AND (T.is_ms_shipped = 0) ' +
      'AND (T.temporal_type = 0) ' +
      'AND (T.is_replicated = 0) ' +
      'AND (C.is_computed = 0) ' +
      'AND (SCHEMA_NAME(T.schema_id) = ''' + ASchemaName + ''') ' +
      'AND (T.name = ''' + ATableName + ''') ' +
      'AND (C.name = ''' + AColumnName + ''') ' +
    'ORDER BY ' +
      'TABLE_SCHEMA ' +
      ',TABLE_NAME ' +
      ',COLUMN_NAME ' +
      ',ORDINAL_POSITION';
end;

function TSQLDBSchemaExtractor.GetSQLbySchemaType(ASchemaType: TSchemaType): string;
begin
  if (ASchemaType = stFull) then
    Result :=
      'SELECT ' +
        'TABLE_SCHEMA = SCHEMA_NAME(T.schema_id) ' +
        ',TABLE_NAME = T.name ' +
        ',ORDINAL_POSITION = C.column_id ' +
        ',COLUMN_NAME = C.name ' +
        ',MAX_LENGHT = C.max_length ' +
        ',DATA_TYPE = TYPE_NAME(C.system_type_id) ' +
        ',COLUMN_IDENTITY = C.is_identity ' +
        //',ROWS = P.rows ' +
      'FROM ' +
        'sys.tables AS T ' +
      'JOIN ' +
        'sys.columns AS C ON T.object_id=C.object_id ' +
      //'JOIN ' +
      //  'sys.partitions AS P on P.object_id=T.object_id ' +
      'WHERE ' +
        '(T.type = ''U'') ' +
        //'AND (T.is_memory_optimized = 0) ' +
        'AND (T.is_ms_shipped = 0) ' +
        'AND (T.temporal_type = 0) ' +
        'AND (T.is_replicated = 0) ' +
        'AND (C.is_computed = 0) ' +
      'ORDER BY ' +
        'TABLE_SCHEMA ' +
        ',TABLE_NAME ' +
        ',COLUMN_NAME ' +
        ',ORDINAL_POSITION'
  else if (ASchemaType = stText) then
    Result :=
      'SELECT ' +
        'TABLE_SCHEMA = SCHEMA_NAME(T.schema_id) ' +
        ',TABLE_NAME = T.name ' +
        ',ORDINAL_POSITION = C.column_id ' +
        ',COLUMN_NAME = C.name ' +
        ',MAX_LENGHT = C.max_length ' +
        ',DATA_TYPE = TYPE_NAME(C.system_type_id) ' +
        ',COLUMN_IDENTITY = C.is_identity ' +
      'FROM ' +
        'sys.tables AS T ' +
      'JOIN ' +
        'sys.columns AS C ON T.object_id=C.object_id ' +
      'WHERE ' +
        '(T.type = ''U'') ' +
        //'AND (T.is_memory_optimized = 0) ' +
        'AND (T.is_ms_shipped = 0) ' +
        'AND (T.temporal_type = 0) ' +
        'AND (T.is_replicated = 0) ' +
        'AND (C.is_computed = 0) ' +
        'AND TYPE_NAME(C.system_type_id) IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''text'', ''ntext'') ' +
      'ORDER BY ' +
        'TABLE_SCHEMA ' +
        ',TABLE_NAME ' +
        ',ORDINAL_POSITION'
  else
    Result := '';
end;

//function TSQLDBSchemaExtractor.GetDBSchemaIndex: TDBSchemaIndex;
//begin
//  Result := FDBSchemaIndex;
//end;

{ TSQLObjectNameFormatter }

class function TSQLObjectNameFormatter.Format(
  AObjectName: string): string;
begin
  Result := '[' + AObjectName + ']';
end;

{ TSQLDBTableInfo }

constructor TSQLDBTableInfo.Create(const ATableSchema, ATableName, AColumnName,
  ADataType: string; const AMaxLength: Integer; const AColumnIdentity: Boolean);
begin
  FTableSchema := ATableSchema;
  FTableName := ATableName;
  FColumnName := AColumnName;
  FMaxLength := AMaxLength;
  FDataType := ADataType;
  FColumnIdentity := AColumnIdentity;
end;

end.

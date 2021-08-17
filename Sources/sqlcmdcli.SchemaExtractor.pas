unit sqlcmdcli.SchemaExtractor;

interface

uses
  System.Generics.Collections
  ,Data.Win.ADODB;

type
  TSQLDBTableInfo = class(TObject)
  protected
    FTableSchema: string;
    FTableName: string;
    FColumnName: string;
    FDataType: string;
    FColumnIdentity: Boolean;
  public
    constructor Create(const ATableSchema, ATableName, AColumnName, ADataType: string;
      const AColumnIdentity: Boolean);
    property TableSchema: string read FTableSchema;
    property TableName: string read FTableName;
    property ColumnName: string read FColumnName;
    property DataType: string read FDataType;
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
  protected
    FConnection: TADOConnection;
    FDBSchema: TDBSchema;
    //FDBSchemaIndex: TDBSchemaIndex;
  public
    constructor Create(AConnection: TADOConnection);
    destructor Destroy; override;
    procedure ExtractSchema;
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

procedure TSQLDBSchemaExtractor.ExtractSchema;
var
  LQry: TADOQuery;
  //LColumn: TSQLDBTableInfo;
  LCurrentTable: string;
  LList: TObjectList<TSQLDBTableInfo>;
  //LIndex: Integer;
begin
  // Logica di estrazione dello schema DB

  LQry := TADOQuery.Create(nil);
  LList := TObjectList<TSQLDBTableInfo>.Create();
  //LColumn := TSQLDBTableInfo.Create();
  //LIndex := 0;
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
        //',ROWS = P.rows ' +
      'FROM ' +
        'sys.tables AS T ' +
      'JOIN ' +
        'sys.columns AS C ON T.object_id=C.object_id ' +
      //'JOIN ' +
      //  'sys.partitions AS P on P.object_id=T.object_id ' +
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
                                         LQry.FieldByName('COLUMN_IDENTITY').AsBoolean
                                         ))
      else begin
        TConsole.Log('Add ' + LCurrentTable, Info, True);
        FDBSchema.Add(LCurrentTable, LList);
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
  ADataType: string; const AColumnIdentity: Boolean);
begin
  FTableSchema := ATableSchema;
  FTableName := ATableName;
  FColumnName := AColumnName;
  FDataType := ADataType;
  FColumnIdentity := AColumnIdentity;
end;

end.

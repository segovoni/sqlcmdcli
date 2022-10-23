unit sqlcmdcli.Boot;

interface

type
  TBootCLI = class(TObject)
  public
    class procedure Boot;
  end;

implementation

uses
  VSoft.CommandLine.Options
  ,sqlcmdcli.Classes
  ,sqlcmdcli.ResourceStrings
  ,sqlcmdcli.CommandOptions
  ,sqlcmdcli.QueryStore
  ,sqlcmdcli.StressDB
  ,sqlcmdcli.AnonymizeDB
  ,sqlcmdcli.AlterColumn;

{ TBootCLI }

class procedure TBootCLI.Boot;
var
  LCommand: TCommandDefinition;
  LOption: IOptionDefinition;
begin

  // Preferences
  TOptionsRegistry.DescriptionTab := 30;
  TOptionsRegistry.NameValueSeparator := ':';

  // Global options

  // Global option verbose
  LOption := TOptionsRegistry.RegisterOption<Boolean>('verbose', 'v',
    RS_CMD_VERBOSE_INFO,
    procedure(const AValue: Boolean)
    begin
      TGlobalOptions.Verbose := AValue;
    end);
  LOption.HasValue := False;

  // Global option: servername
  LOption := TOptionsRegistry.RegisterOption<string>('servername', 's',
    RS_CMD_SERVERNAME_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.ServerName := AValue;
    end);
  LOption.Required := True;

  // Global option: databasename
  LOption := TOptionsRegistry.RegisterOption<string>('databasename', 'd',
    RS_CMD_DATABASENAME_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.DatabaseName := AValue;
    end);
  LOption.Required := True;

  // Global option: username
  LOption := TOptionsRegistry.RegisterOption<string>('username', 'u',
    RS_CMD_USERNAME_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.UserName := AValue;
    end);
  LOption.Required := True;

  // Global option: password
  LOption := TOptionsRegistry.RegisterOption<string>('password', 'p',
    RS_CMD_PASSWORD_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.Password := AValue;
    end);
  LOption.Required := True;

  // Operation: Help

  // Command: help
  LCommand := TOptionsRegistry.RegisterCommand('help', '?',
    RS_CMD_HELP_DESCRIPTION, RS_CMD_HELP_INFO,
    'help <command>');

  // Option: "command"
  LOption := LCommand.RegisterUnNamedOption<string>(
    RS_CMD_HELP_COMMANDINFO, 'command',
    procedure(const AValue: string)
    begin
      if Length(AValue) > 0 then
        THelpOptions.CommandName := AValue
      else
        THelpOptions.CommandName := 'help';
    end);
  LOption.Required := False;

  // Operation: Query Store Workload

  // Command: querystoreworkload
  LCommand := TOptionsRegistry.RegisterCommand('querystoreworkload', 'qsw',
    RS_CMD_QSWORKLOAD_DESCRIPTION, RS_CMD_QSWORKLOAD_INFO,
    'querystoreworkload -servername:<name> -databasename:<dbname> -username:<name> -password:<password>');
  LCommand.Examples.Add('querystoreworkload -servername:MARCONI -databasename:AdventureWorks -username:sgovoni -password:royalbreeze489 -psp');
  LCommand.Examples.Add('querystoreworkload -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489 -psp');
  LCommand.Examples.Add('qsw -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489 -psp');

  // Option: "psp" parameter sensitive plan optimization
  LOption := LCommand.RegisterOption<Boolean>('psp', 'psp',
    RS_CMD_QSWORKLOAD_PSPINFO,
    procedure(const AValue: Boolean)
    begin
      TQueryStoreWorkloadOptions.PSP := AValue
    end);
  LOption.Required := False;
  LOption.HasValue := False;

  TCommandHandler.RegisterCommand('querystoreworkload',
    procedure()
    begin
      TQueryStoreWorkload.Run(
        TGlobalOptions.ServerName,
        TGlobalOptions.DatabaseName,
        TGlobalOptions.UserName,
        TGlobalOptions.Password,
        TQueryStoreWorkloadOptions.PSP,
        TGlobalOptions.Verbose);
    end);

  // Operation: Stress database

  // Command: stressdb
  LCommand := TOptionsRegistry.RegisterCommand('stressdb', 'sdb',
    RS_CMD_STRESSDB_DESCRIPTION, RS_CMD_STRESSDB_INFO,
    'stressdb -servername:<name> -databasename:<dbname> -username:<name> -password:<password>');
  LCommand.Examples.Add('stressdb -servername:MARCONI -databasename:AdventureWorks -username:sgovoni -password:royalbreeze489');
  LCommand.Examples.Add('stressdb -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489');
  LCommand.Examples.Add('sdb -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489');

  TCommandHandler.RegisterCommand('stressdb',
    procedure()
    begin
      TStressDB.Run(
        TGlobalOptions.ServerName,
        TGlobalOptions.DatabaseName,
        TGlobalOptions.UserName,
        TGlobalOptions.Password,
        TGlobalOptions.Verbose,
        TStressDBOptions.MeltCPU);
    end);

  // Operation: Anonymize database

  // Command: anonymizedb
  LCommand := TOptionsRegistry.RegisterCommand('anonymizedb', 'anondb',
    RS_CMD_ANONYMIZEDB_DESCRIPTION, RS_CMD_ANONYMIZEDB_INFO,
    'anonymizedb -servername:<name> -databasename:<dbname> -username:<name> ' +
    '-password:<password> -schemaname:<tableschema> -tablename:<tablename> ' +
    '-columnname:<columnname>');
  LCommand.Examples.Add('anonymizedb -servername:MARCONI -databasename:AdventureWorks ' +
    '-username:sgovoni -password:royalbreeze489');
  LCommand.Examples.Add('anonymizedb -s:MARCONI -d:AdventureWorks -u:sgovoni ' +
    '-p:royalbreeze489');
  LCommand.Examples.Add('anondb -s:MARCONI -d:AdventureWorks -u:sgovoni ' +
    '-p:royalbreeze489');
  LCommand.Examples.Add('anonymizedb -servername:MARCONI -databasename:AdventureWorks ' +
    '-username:sgovoni -password:royalbreeze489 -schemaname:Person -tablename:Address ' +
    '-columnname:City');
  LCommand.Examples.Add('anonymizedb -servername:MARCONI -databasename:AdventureWorks ' +
    '-username:sgovoni -password:royalbreeze489 -schema:Person -table:Address ' +
    '-column:City');

  // Option: "schemaname"
  LOption := LCommand.RegisterOption<string>('schemaname', 'schema',
    RS_CMD_ANONYMIZEDB_SCHEMANAMEINFO,
    procedure(const AValue: string)
    begin
      TAnonymizeDBOptions.SchemaName := AValue
    end);
  LOption.Required := False;

  // Option: "tablename"
  LOption := LCommand.RegisterOption<string>('tablename', 'table',
    RS_CMD_ANONYMIZEDB_TABLENAMEINFO,
    procedure(const AValue: string)
    begin
      TAnonymizeDBOptions.TableName := AValue
    end);
  LOption.Required := False;

  // Option: "columnname"
  LOption := LCommand.RegisterOption<string>('columnname', 'column',
    RS_CMD_ANONYMIZEDB_COLUMNNAMEINFO,
    procedure(const AValue: string)
    begin
      TAnonymizeDBOptions.ColumnName := AValue
    end);
  LOption.Required := False;

  TCommandHandler.RegisterCommand('anonymizedb',
    procedure()
    begin
      TAnonymizeDB.Run(
        TGlobalOptions.ServerName,
        TGlobalOptions.DatabaseName,
        TGlobalOptions.UserName,
        TGlobalOptions.Password,
        TAnonymizeDBOptions.SchemaName,
        TAnonymizeDBOptions.TableName,
        TAnonymizeDBOptions.ColumnName,
        TGlobalOptions.Verbose);
    end);

  // Operation: Alter column

  // Command: altercolumn
  LCommand := TOptionsRegistry.RegisterCommand('altercolumn', 'altercol',
    RS_CMD_ALTERCOLUMN_DESCRIPTION, RS_CMD_ALTERCOLUMN_INFO,
    'altercolumn -servername:<name> -databasename:<dbname> -username:<name> ' +
                '-password:<password> -schemaname:<tableschema> ' +
                '-tablename:<tablename> -columnname:<columnname> ' +
                '-columnrename:<columnrename> -datatype:<datatype>');
  LCommand.Examples.Add('altercolumn -servername:MARCONI ' +
    '-databasename:AdventureWorks ' +
    '-username:sgovoni -password:royalbreeze489 -schemaname:Person ' +
    '-tablename:Person -columnname:FirstName -datatype:nvarchar(100)');
  LCommand.Examples.Add('altercolumn -s:MARCONI -d:AdventureWorks ' +
    '-u:sgovoni -p:royalbreeze489 -schema:Person -table:Person ' +
    '-column:FirstName -type:nvarchar(100)');
  LCommand.Examples.Add('altercol -s:MARCONI -d:AdventureWorks ' +
    '-u:sgovoni -p:royalbreeze489 -schema:Person -table:Person ' +
    '-column:FirstName -type:nvarchar(100)');

  // Option: "schemaname"
  LOption := LCommand.RegisterOption<string>('schemaname', 'schema',
    RS_CMD_ALTERCOLUMN_SCHEMANAMEINFO,
    procedure(const AValue: string)
    begin
      TAlterColumnOptions.SchemaName := AValue
    end);
  LOption.Required := True;

  // Option: "tablename"
  LOption := LCommand.RegisterOption<string>('tablename', 'table',
    RS_CMD_ALTERCOLUMN_TABLENAMEINFO,
    procedure(const AValue: string)
    begin
      TAlterColumnOptions.TableName := AValue
    end);
  LOption.Required := True;

  // Option: "columnname"
  LOption := LCommand.RegisterOption<string>('columnname', 'column',
    RS_CMD_ALTERCOLUMN_COLUMNNAMEINFO,
    procedure(const AValue: string)
    begin
      TAlterColumnOptions.ColumnName := AValue
    end);
  LOption.Required := True;

  // Option: "columnrename"
  LOption := LCommand.RegisterOption<string>('columnrename', 'columnrename',
    RS_CMD_ALTERCOLUMN_COLUMNRENAMEINFO,
    procedure(const AValue: string)
    begin
      TAlterColumnOptions.ColumnRename := AValue
    end);
  LOption.Required := False;

  // Option: "datatype"
  LOption := LCommand.RegisterOption<string>('datatype', 'type',
    RS_CMD_ALTERCOLUMN_DATATYPEINFO,
    procedure(const AValue: string)
    begin
      TAlterColumnOptions.DataType := AValue
    end);
  LOption.Required := True;

  TCommandHandler.RegisterCommand('altercolumn',
    procedure()
    begin
      TAlterColumn.Run(
        TGlobalOptions.ServerName,
        TGlobalOptions.DatabaseName,
        TGlobalOptions.UserName,
        TGlobalOptions.Password,
        TAlterColumnOptions.SchemaName,
        TAlterColumnOptions.TableName,
        TAlterColumnOptions.ColumnName,
        TAlterColumnOptions.ColumnRename,
        TAlterColumnOptions.DataType,
        TGlobalOptions.Verbose);
    end);
end;

end.

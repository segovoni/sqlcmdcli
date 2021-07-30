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
  ,sqlcmdcli.StressDB;

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

  // Option verbose
  LOption := TOptionsRegistry.RegisterOption<Boolean>('verbose', 'v',
    RS_CMD_VERBOSE_INFO,
    procedure(const AValue: Boolean)
    begin
      TGlobalOptions.Verbose := AValue;
    end);
  LOption.HasValue := False;

  // Option: servername
  LOption := TOptionsRegistry.RegisterOption<string>('servername', 's',
    RS_CMD_SERVERNAME_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.ServerName := AValue;
    end);
  LOption.Required := True;

  // Option: databasename
  LOption := TOptionsRegistry.RegisterOption<string>('databasename', 'd',
    RS_CMD_DATABASENAME_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.DatabaseName := AValue;
    end);
  LOption.Required := True;

  // Option: username
  LOption := TOptionsRegistry.RegisterOption<string>('username', 'u',
    RS_CMD_USERNAME_INFO,
    procedure(const AValue: string)
    begin
      TGlobalOptions.UserName := AValue;
    end);
  LOption.Required := True;

  // Option: password
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
  LCommand.Examples.Add('querystoreworkload -servername:MARCONI -databasename:AdventureWorks -username:sgovoni -password:royalbreeze489');
  LCommand.Examples.Add('querystoreworkload -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489');
  LCommand.Examples.Add('qsw -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489');

  TCommandHandler.RegisterCommand('querystoreworkload',
    procedure()
    begin
      TQueryStoreWorkload.Run(
        TGlobalOptions.ServerName,
        TGlobalOptions.DatabaseName,
        TGlobalOptions.UserName,
        TGlobalOptions.Password,
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
end;

end.

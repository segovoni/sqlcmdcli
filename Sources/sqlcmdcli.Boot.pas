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
  ,sqlcmdcli.QueryStore;

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

  // Operation: Help

  // Command: "help"
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

  // Command: "Run"
  LCommand := TOptionsRegistry.RegisterCommand('querystoreworkload', 'qsw',
    RS_CMD_QSWORKLOAD_DESCRIPTION, RS_CMD_QSWORKLOAD_INFO,
    'run -servername:<name> -databasename:<dbname> -username:<name> -password:<password>');
  LCommand.Examples.Add('querystoreworkload -servername:MARCONI -databasename:AdventureWorks -username:sgovoni -password:royalbreeze489');
  LCommand.Examples.Add('querystoreworkload -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489');
  LCommand.Examples.Add('qsw -s:MARCONI -d:AdventureWorks -u:sgovoni -p:royalbreeze489');

  // Option: "servername"
  LOption := LCommand.RegisterOption<string>('servername', 's',
    RS_CMD_QSWORKLOAD_SERVERNAME_INFO,
    procedure(const AValue: string)
    begin
      TQueryStoreWorkloadOptions.ServerName := AValue;
    end);
  LOption.Required := True;

  // Option: "databasename"
  LOption := LCommand.RegisterOption<string>('databasename', 'd',
    RS_CMD_QSWORKLOAD_DATABASENAME_INFO,
    procedure(const AValue: string)
    begin
      TQueryStoreWorkloadOptions.DatabaseName := AValue;
    end);
  LOption.Required := True;

  // Option: "username"
  LOption := LCommand.RegisterOption<string>('username', 'u',
    RS_CMD_QSWORKLOAD_USERNAME_INFO,
    procedure(const AValue: string)
    begin
      TQueryStoreWorkloadOptions.UserName := AValue;
    end);
  LOption.Required := True;

  // Option: "password"
  LOption := LCommand.RegisterOption<string>('password', 'p',
    RS_CMD_QSWORKLOAD_PASSWORD_INFO,
    procedure(const AValue: string)
    begin
      TQueryStoreWorkloadOptions.Password := AValue;
    end);
  LOption.Required := True;

  TCommandHandler.RegisterCommand('querystoreworkload',
    procedure()
    begin
      TQueryStoreWorkload.Run(
        TQueryStoreWorkloadOptions.ServerName,
        TQueryStoreWorkloadOptions.DatabaseName,
        TQueryStoreWorkloadOptions.UserName,
        TQueryStoreWorkloadOptions.Password,
        TGlobalOptions.Verbose);
    end);
end;

end.

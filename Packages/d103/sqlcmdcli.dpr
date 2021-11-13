program sqlcmdcli;

{$APPTYPE CONSOLE}

{$IFDEF MSWINDOWS}
{$ENDIF}

//{$R *.res}
{$R *.dres}

uses
  System.SysUtils,
  VSoft.CommandLine.CommandDef,
  VSoft.CommandLine.OptionDef,
  VSoft.CommandLine.Options,
  sqlcmdcli.Boot in '..\..\Sources\sqlcmdcli.Boot.pas',
  sqlcmdcli.Classes in '..\..\Sources\sqlcmdcli.Classes.pas',
  sqlcmdcli.Console in '..\..\Sources\sqlcmdcli.Console.pas',
  sqlcmdcli.Datasource in '..\..\Sources\sqlcmdcli.Datasource.pas' {DataModule1: TDataModule},
  sqlcmdcli.CommandOptions in '..\..\Sources\sqlcmdcli.CommandOptions.pas',
  sqlcmdcli.ResourceStrings in '..\..\Sources\sqlcmdcli.ResourceStrings.pas',
  sqlcmdcli.Utils in '..\..\Sources\sqlcmdcli.Utils.pas',
  sqlcmdcli.QueryStore in '..\..\Sources\sqlcmdcli.QueryStore.pas',
  sqlcmdcli.StressDB.QueryExecutor in '..\..\Sources\sqlcmdcli.StressDB.QueryExecutor.pas',
  sqlcmdcli.StressDB in '..\..\Sources\sqlcmdcli.StressDB.pas',
  sqlcmdcli.SchemaExtractor in '..\..\Sources\sqlcmdcli.SchemaExtractor.pas',
  sqlcmdcli.AnonymizeDB in '..\..\Sources\sqlcmdcli.AnonymizeDB.pas',
  sqlcmdcli.AlterColumn in '..\..\Sources\sqlcmdcli.AlterColumn.pas',
  sqlcmdcli.Constants in '..\..\Sources\sqlcmdcli.Constants.pas';

var
  LHeader: string;
  LParseResult: ICommandLineParseResult;

begin
  try
    {$IFDEF MSWINDOWS}
    LHeader := TResourceUtils.GetResourceString('sqlcmdcli', 'TEXT');
    Writeln(LHeader);
    {$ENDIF}

    //TConsole.SetTitle('')

    // Check SQL Server Native Client
    //if not TSQLUtils.CheckNativeClient(SQL_SERVER_NATIVE_CLIENT_11) then
    //begin
    //  ExitCode := 1;
    //  Writeln;
    //  Writeln(Format(RS_ERROR_SQL_SERVER_NATIVE_CLIENT, [SQL_SERVER_NATIVE_CLIENT_11]));
    //  Exit;
    //end;

    // CLI Initialize
    TBootCLI.Boot;

    LParseResult := TOptionsRegistry.Parse;

    if LParseResult.HasErrors then
    begin
      ExitCode := 1;
      Writeln;
      Writeln(LParseResult.ErrorText);
      Exit;
    end;

    if (LParseResult.Command = EmptyStr) Or (LParseResult.Command = 'help') then
    begin
      TOptionsRegistry.PrintUsage(THelpOptions.CommandName,
        procedure(const AUsage: string)
        begin
          Writeln(AUsage);
        end);
      Exit;
    end;

    TCommandHandler.ExecuteCommand(LParseResult.Command);

    Readln;
  except
      on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
        ExitCode := 1;
      end;
  end;
end.

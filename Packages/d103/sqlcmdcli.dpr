program sqlcmdcli;

{$APPTYPE CONSOLE}
{$R *.res}

{$IFDEF MSWINDOWS}

{$ENDIF}

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
  sqlcmdcli.QueryStore in '..\..\Sources\sqlcmdcli.QueryStore.pas';

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

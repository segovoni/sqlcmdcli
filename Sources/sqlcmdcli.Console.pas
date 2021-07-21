unit sqlcmdcli.Console;

interface

uses
  WinApi.Windows;

type
  TConsoleForegroundColor = (
    GreenForeground = FOREGROUND_GREEN,
    NavyForeground = FOREGROUND_BLUE,
    RedForeground = FOREGROUND_INTENSITY or FOREGROUND_RED,
    LimeForeground = FOREGROUND_INTENSITY or FOREGROUND_GREEN
  );

  TConsoleBackgroundColor = (
    BlackBackground = 0
  );

  TConsoleState = (Default, Info, Success, Warning, Error);

  TConsole = class(TObject)
  private
    class var FHandle: Cardinal;
  public
    class constructor Create;
    class procedure SetForegroundColor(const AValue: TConsoleForegroundColor);
    class procedure SetBackgroundColor(const AValue: TConsoleBackgroundColor);
    class procedure SetTitle(const AValue: string);
    class procedure Log(const AMessage: string; AState: TConsoleState;
      const ANewLine: Boolean);
  end;

implementation

{ TConsole }

class constructor TConsole.Create;
begin
  inherited;
  FHandle := GetStdHandle(STD_OUTPUT_HANDLE);
end;

class procedure TConsole.SetBackgroundColor(
  const AValue: TConsoleBackgroundColor);
begin

end;

class procedure TConsole.SetForegroundColor(
  const AValue: TConsoleForegroundColor);
begin
  //SetConsoleTextAttribute(FHandle, AValue);
end;

class procedure TConsole.SetTitle(const AValue: string);
begin

end;

class procedure TConsole.Log(const AMessage: string; AState: TConsoleState;
  const ANewLine: Boolean);
begin
  case AState of
    Default: SetForegroundColor(GreenForeground);
    Info: SetForegroundColor(NavyForeground);
    Success: SetForegroundColor(GreenForeground);
    Warning: SetForegroundColor(RedForeground);
    Error: SetForegroundColor(RedForeground);
  end;
  if ANewLine then
    Writeln(AMessage)
  else
    Write(AMessage);
end;

end.

unit sqlcmdcli.Console;

interface

uses
  WinApi.Windows;

type
  TConsoleForegroundColor = (
    BlackForeground = 0,
    GreenForeground = FOREGROUND_GREEN,
    NavyForeground = FOREGROUND_BLUE,
    GrayForeground = FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE,
    AquaForeground = FOREGROUND_INTENSITY or FOREGROUND_GREEN or FOREGROUND_BLUE,
    RedForeground = FOREGROUND_INTENSITY or FOREGROUND_RED,
    LimeForeground = FOREGROUND_INTENSITY or FOREGROUND_GREEN,
    WhiteForeground = FOREGROUND_INTENSITY or FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE
  );

  TConsoleBackgroundColor = (
    BlackBackground = 0,
    WhiteBackground = BACKGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE
  );

  TConsoleState = (Default, Info, Success, Warning, Error);

  TConsole = class(TObject)
  private
    class var FHandle: Cardinal;
    class var FConOut: THandle;
    class var FBufInfo: TConsoleScreenBufferInfo;
  public
    class constructor Create;
    class procedure SetForegroundColor(const AValue: TConsoleForegroundColor);
    //class procedure SetBackgroundColor(const AValue: TConsoleBackgroundColor);
    class procedure SetTitle(const AValue: string);
    class procedure Log(const AMessage: string; AState: TConsoleState;
      const ANewLine: Boolean);
  end;

implementation

uses
  sqlcmdcli.Constants;

{ TConsole }

class constructor TConsole.Create;
begin
  inherited;
  FHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  // Get console screen buffer handle
  FConOut := TTextRec(Output).Handle;
  // Save current text attributes
  GetConsoleScreenBufferInfo(FConOut, FBufInfo);
end;

class procedure TConsole.SetForegroundColor(
  const AValue: TConsoleForegroundColor);
begin
  SetConsoleTextAttribute(FHandle, Word(AValue));
end;

class procedure TConsole.SetTitle(const AValue: string);
begin
  SetConsoleTitle(PChar(AValue));
end;

class procedure TConsole.Log(const AMessage: string; AState: TConsoleState;
  const ANewLine: Boolean);
var
  LConOut: THandle;
  LBufInfo: TConsoleScreenBufferInfo;
begin
  // Get console screen buffer handle
  LConOut := TTextRec(Output).Handle;

  // Save current text attributes
  GetConsoleScreenBufferInfo(LConOut, LBufInfo);

  case AState of
    Default:   SetConsoleTextAttribute(FConOut, FBufInfo.wAttributes);
    Info: SetForegroundColor(AquaForeground);
    Success: SetForegroundColor(GreenForeground);
    Warning: SetForegroundColor(RedForeground);
    Error: SetForegroundColor(RedForeground);
  else
    SetForegroundColor(BlackForeground);
  end;

  if ANewLine then
    Writeln(AMessage)
  else
    Write(AMessage);

  // Reset to defaults
  SetConsoleTextAttribute(LConOut, LBufInfo.wAttributes);
end;

end.

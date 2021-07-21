unit sqlcmdcli.Classes;

interface

uses
  System.Generics.Collections
  ,System.SysUtils;

type
  TCommandHandler = class(TObject)
  private
    class var FCommandHandlers: TDictionary<string, TProc>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure RegisterCommand(const ACommandName: string; AProc: TProc);
    class procedure ExecuteCommand(const ACommandName: string);
  end;

implementation

uses
  sqlcmdcli.ResourceStrings;

{ TCommandHandler }

class constructor TCommandHandler.Create;
begin
  inherited;
  FCommandHandlers := TDictionary<string, TProc>.Create;
end;

class destructor TCommandHandler.Destroy;
begin
  inherited;
  FreeAndNil(FCommandHandlers);
end;

class procedure TCommandHandler.ExecuteCommand(const ACommandName: string);
var
  LProc: TProc;
begin
  if not FCommandHandlers.TryGetValue(ACommandName, LProc) then
    raise Exception.Create(Format(RS_ERROR_COMMAND_UNKNOWN, [ACommandName]));
  LProc();
end;

class procedure TCommandHandler.RegisterCommand(const ACommandName: string;
  AProc: TProc);
begin
  FCommandHandlers.Add(ACommandName, AProc);
end;

end.

unit sqlcmdcli.Utils;

interface

type

  TResourceUtils = class(TObject)
    public
      class function GetResourceString(const AResourceName, AResourceType: string): string;
  end;

implementation

uses
  System.Classes;

{ TResourceUtils }

class function TResourceUtils.GetResourceString(const AResourceName,
  AResourceType: string): string;
var
  LStream: TResourceStream;
  LStrings: TStringList;
begin
  LStream := TResourceStream.Create(HInstance, AResourceName, PChar(AResourceType));
  try
    LStrings := TStringList.Create;
    try
      LStream.Position := 0;
      LStrings.Clear;
      LStrings.LoadFromStream(LStream);
      Result := LStrings.Text;
    finally
      LStrings.Free
    end;
  finally
    LStream.Free;
  end;
end;

end.

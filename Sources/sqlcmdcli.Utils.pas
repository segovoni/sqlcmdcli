unit sqlcmdcli.Utils;

interface

type

  TResourceUtils = class(TObject)
  public
    class function GetResourceString(const AResourceName, AResourceType: string): string;
  end;

  TStringUtils = class(TObject)
  public
    class function StringScrambler(const AValue: string): string;
  end;

implementation

uses
  System.Classes
  ,System.StrUtils;

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

{ TStringUtils }

class function TStringUtils.StringScrambler(const AValue: string): string;
begin
  // "abcd" --> "dbca"
  if (Length(AValue) > 2) then
    Result := RightStr(AValue, 1) + Copy(AValue, 2, Length(AValue)-2) + LeftStr(AValue, 1)
  else if (Length(AValue) = 2) then
    Result := ReverseString(AValue)
  else
    Result := AValue;
end;

end.

unit OpenAI.Chat.Functions.Samples;

interface

uses
  System.SysUtils, OpenAI.Chat.Functions;

type
  TChatFunctionWeather = class(TChatFunction)
  protected
    function GetDescription: string; override;
    function GetName: string; override;
    function GetParameters: string; override;
  public
    constructor Create; override;
    function Execute(const Args: string): string; override;
  end;

implementation

uses
  System.JSON;

{ TChatFunctionWeather }

constructor TChatFunctionWeather.Create;
begin
  inherited;
end;

function TChatFunctionWeather.Execute(const Args: string): string;
var
  JSON: TJSONObject;
  Location: string;
  UnitKind: string;
begin
  Result := '';
  // Parse arguments
  try
    JSON := TJSONObject.ParseJSONValue(Args) as TJSONObject;
    if Assigned(JSON) then
    try
      Location := JSON.GetValue('location', '');
      UnitKind := JSON.GetValue('unit', '');
    finally
      JSON.Free;
    end;
  except
    JSON := nil;
  end;
  // Invalid arguments
  if (not Assigned(JSON)) or Location.IsEmpty then
    Exit;

  // Generate response
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('location', Location);
    JSON.AddPair('unit', UnitKind);

    JSON.AddPair('temperature', TJSONNumber.Create(72));
    JSON.AddPair('forecast', TJSONArray.Create('sunny', 'windy'));

    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end;

function TChatFunctionWeather.GetDescription: string;
begin
  Result := 'Get the current weather in a given location';
end;

function TChatFunctionWeather.GetName: string;
begin
  Result := 'get_current_weather';
end;

function TChatFunctionWeather.GetParameters: string;
begin
  var JSON := TJSONObject.Create;
  try
    JSON.AddPair('type', 'object');
    JSON.AddPair('required', TJSONArray.Create(TJSONString.Create('location')));
    var Props := TJSONObject.Create;
    JSON.AddPair('properties', Props);
    var Prop := TJSONObject.Create(TJSONPair.Create('type', 'string'));
    Prop.AddPair('description', 'The city and state, e.g. San Francisco, CA');
    Props.AddPair('location', Prop);
    Prop := TJSONObject.Create(TJSONPair.Create('type', 'string'));
    Prop.AddPair('enum', TJSONArray.Create('celsius', 'fahrenheit'));
    Props.AddPair('unit', Prop);
    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end;

end.


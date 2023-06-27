unit OpenAI.Chat.Functions;

interface

uses
  System.JSON;

type
  IChatFunction = interface
    ['{F2B4D026-5FA9-4499-B5D1-3FEA4885C511}']
    function GetDescription: string;
    function GetName: string;
    function GetParameters: string;
    function Execute(const Args: string): string;
    property Description: string read GetDescription;
    property Name: string read GetName;
    property Parameters: string read GetParameters;
  end;

  TChatFunction = class abstract(TInterfacedObject, IChatFunction)
  protected
    function GetDescription: string; virtual; abstract;
    function GetName: string; virtual; abstract;
    function GetParameters: string; virtual; abstract;
  public
    property Description: string read GetDescription;
    property Name: string read GetName;
    property Parameters: string read GetParameters;
    function Execute(const Args: string): string; virtual;
    class function ToJson(Value: IChatFunction): TJSONObject;
    constructor Create; virtual;
  end;

implementation

{ TChatFunction }

constructor TChatFunction.Create;
begin
  inherited;
end;

function TChatFunction.Execute(const Args: string): string;
begin
  Result := '';
end;

class function TChatFunction.ToJson(Value: IChatFunction): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Value.GetName);
  Result.AddPair('description', Value.GetDescription);
  Result.AddPair('parameters', TJSONObject.ParseJSONValue(Value.GetParameters));
end;

end.


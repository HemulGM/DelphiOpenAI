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
    function GetStrict: Boolean;
    function Execute(const Args: string): string;
    /// <summary>
    /// A description of what the function does, used by the model to choose when and how to call the function.
    /// </summary>
    property Description: string read GetDescription;
    /// <summary>
    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
    /// with a maximum length of 64.
    /// </summary>
    property Name: string read GetName;
    /// <summary>
    /// The parameters the functions accepts, described as a JSON Schema object.
    /// See the guide for examples, and the JSON Schema reference for documentation about the format.
    ///
    /// To describe a function that accepts no parameters, provide the value {"type": "object", "properties": {}}.
    /// </summary>
    /// <seealso>https://json-schema.org/understanding-json-schema/</seealso>
    property Parameters: string read GetParameters;
    /// <summary>
    /// Whether to enable strict schema adherence when generating the function call.
    /// If set to true, the model will follow the exact schema defined in the parameters field.
    /// Only a subset of JSON Schema is supported when strict is true.
    /// Learn more about Structured Outputs in the function calling guide.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/api-reference/chat/docs/guides/function-calling</seealso>
    property strict: Boolean read GetStrict;
  end;

  TChatFunction = class abstract(TInterfacedObject, IChatFunction)
  protected
    function GetDescription: string; virtual; abstract;
    function GetName: string; virtual; abstract;
    function GetParameters: string; virtual; abstract;
    function GetStrict: Boolean; virtual;
  public
    /// <summary>
    /// A description of what the function does, used by the model to choose when and how to call the function.
    /// </summary>
    property Description: string read GetDescription;
    /// <summary>
    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
    /// with a maximum length of 64.
    /// </summary>
    property Name: string read GetName;
    /// <summary>
    /// The parameters the functions accepts, described as a JSON Schema object.
    /// See the guide for examples, and the JSON Schema reference for documentation about the format.
    ///
    /// To describe a function that accepts no parameters, provide the value {"type": "object", "properties": {}}.
    /// </summary>
    /// <seealso>https://json-schema.org/understanding-json-schema/</seealso>
    property Parameters: string read GetParameters;
    /// <summary>
    /// Whether to enable strict schema adherence when generating the function call.
    /// If set to true, the model will follow the exact schema defined in the parameters field.
    /// Only a subset of JSON Schema is supported when strict is true.
    /// Learn more about Structured Outputs in the function calling guide.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/api-reference/chat/docs/guides/function-calling</seealso>
    property strict: Boolean read GetStrict;
    function Execute(const Args: string): string; virtual;
    class function ToJson(Value: IChatFunction): TJSONObject;
    constructor Create; virtual;
  end;

implementation

uses
  System.SysUtils;

{ TChatFunction }

constructor TChatFunction.Create;
begin
  inherited;
end;

function TChatFunction.Execute(const Args: string): string;
begin
  Result := '';
end;

function TChatFunction.GetStrict: Boolean;
begin
  Result := False;
end;

class function TChatFunction.ToJson(Value: IChatFunction): TJSONObject;
begin
  Result := TJSONObject.Create;
  try
    Result.AddPair('name', Value.GetName);
    Result.AddPair('description', Value.GetDescription);
    Result.AddPair('parameters', TJSONObject.ParseJSONValue(Value.GetParameters));
  except
    on E: Exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

end.


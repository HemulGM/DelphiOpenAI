unit OpenAI.Assistants;

interface

uses
  System.SysUtils, Rest.Json, Rest.Json.Types, REST.JsonReflect, System.JSON, OpenAI.API,
  OpenAI.API.Params, OpenAI.Types;

type
  TAssistantTool = class abstract(TJSONParam)
    //Code interpreter tool
    //Retrieval tool
    //Function tool

  end;

  TAssistantCodeInterpreterTool = class(TAssistantTool)
  end;

  TAssistantRetrievalTool = class(TAssistantTool)
  end;

  TAssistantFunctionTool = class(TAssistantTool)
    /// <summary>
    /// A description of what the function does, used by the model to choose when and how to call the function.
    /// </summary>
    function Description(const Value: string): TAssistantFunctionTool;
    /// <summary>
    /// The name of the function to be called. Must be a-z, A-Z, 0-9,
    /// or contain underscores and dashes, with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TAssistantFunctionTool;
    /// <summary>
    /// The parameters the functions accepts, described as a JSON Schema object.
    /// See the guide for examples, and the JSON Schema reference for documentation about the format.
    /// <br>
    /// To describe a function that accepts no parameters, provide the value {"type": "object", "properties": {}}.
    /// </summary>
    function Parameters(const Value: TJSONObject): TAssistantFunctionTool;
  end;

  TAssistantListParams = class(TJSONParam)
    /// <summary>
    /// A cursor for use in pagination. after is an object ID that defines your place in the list.
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo,
    /// your subsequent call can include after=obj_foo in order to fetch the next page of the list.
    /// </summary>
    function After(const Value: string): TAssistantListParams;
    /// <summary>
    /// A cursor for use in pagination. before is an object ID that defines your place in the list.
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo,
    /// your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
    /// </summary>
    function Before(const Value: string): TAssistantListParams;
    /// <summary>
    /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
    /// </summary>
    function Limit(const Value: Integer): TAssistantListParams;
    /// <summary>
    /// Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
    /// </summary>
    function Order(const Value: string): TAssistantListParams;
  end;

  TAssistantParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. You can use the List models API to see all of your available models,
    /// or see our Model overview for descriptions of them.
    /// </summary>
    function Model(const Value: string): TAssistantParams;
    /// <summary>
    /// The name of the assistant. The maximum length is 256 characters.
    /// </summary>
    function Name(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// The description of the assistant. The maximum length is 512 characters.
    /// </summary>
    function Description(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// The system instructions that the assistant uses. The maximum length is 32768 characters.
    /// </summary>
    function Instructions(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant.
    /// Tools can be of types code_interpreter, retrieval, or function.
    /// </summary>
    function Tools(const Value: TArray<TAssistantTool>): TAssistantParams; overload;
    /// <summary>
    /// A list of file IDs attached to this assistant. There can be a maximum of 20 files
    /// attached to the assistant. Files are ordered by their creation date in ascending order.
    /// </summary>
    function FileIds(const Value: TArray<string>): TAssistantParams;
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful
    /// for storing additional information about the object in a structured format.
    /// Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    /// </summary>
    function Metadata(const Value: TJSONParam): TAssistantParams;
    constructor Create; override;
  end;

  TMetadata = class
  end;

  TFunctionParameters = class
  end;

  TToolFunction = class
  private
    [JsonNameAttribute('name')]
    FName: string;
    [JsonNameAttribute('description')]
    FDescription: string;
    [JsonNameAttribute('parameters')]
    FParameters: TFunctionParameters;
  public
    /// <summary>
    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
    /// with a maximum length of 64.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// A description of what the function does, used by the model to choose when and how to call the function.
    /// </summary>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// The parameters the functions accepts, described as a JSON Schema object. See the guide for examples,
    /// and the JSON Schema reference for documentation about the format.
    /// To describe a function that accepts no parameters, provide the value {"type": "object", "properties": {}}.
    /// </summary>
    property Parameters: TFunctionParameters read FParameters write FParameters;
    destructor Destroy; override;
  end;

  TTool = class
  private
    [JsonNameAttribute('type')]
    FType: string;
    [JsonNameAttribute('function')]
    FFunction: TToolFunction;
  public
    property &Type: string read FType write FType;
    property &Function: TToolFunction read FFunction write FFunction;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents an assistant that can call the model and use tools.
  /// </summary>
  TAssistant = class
  private
    [JsonNameAttribute('id')]
    FId: string;
    [JsonNameAttribute('object')]
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('name')]
    FName: string;
    [JsonNameAttribute('description')]
    FDescription: string;
    [JsonNameAttribute('model')]
    FModel: string;
    [JsonNameAttribute('instructions')]
    FInstructions: string;
    [JsonNameAttribute('tools')]
    FTools: TArray<TTool>;
    [JsonNameAttribute('file_ids')]
    FFileIds: TArray<string>;
    [JsonNameAttribute('metadata')]
    FMetadata: TMetadata;
  public
    /// <summary>
    /// The identifier, which can be referenced in API endpoints.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type, which is always assistant.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The Unix timestamp (in seconds) for when the assistant was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// The name of the assistant. The maximum length is 256 characters.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// The description of the assistant. The maximum length is 512 characters.
    /// </summary>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// ID of the model to use. You can use the List models API to see all of your available models,
    /// or see our Model overview for descriptions of them.
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// The system instructions that the assistant uses. The maximum length is 32768 characters.
    /// </summary>
    property Instructions: string read FInstructions write FInstructions;
    /// <summary>
    /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant.
    /// Tools can be of types code_interpreter, retrieval, or function.
    /// </summary>
    property Tools: TArray<TTool> read FTools write FTools;
    /// <summary>
    /// A list of file IDs attached to this assistant.
    /// There can be a maximum of 20 files attached to the assistant.
    /// Files are ordered by their creation date in ascending order.
    /// </summary>
    property FileIds: TArray<string> read FFileIds write FFileIds;
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object.
    /// This can be useful for storing additional information about the object in a structured format.
    /// Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    /// </summary>
    property Metadata: TMetadata read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  TAssistants = class
  private
    FObject: string;
    FData: TArray<TAssistant>;
    FHas_more: Boolean;
    FLast_id: string;
    FFirst_id: string;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TAssistant> read FData write FData;
    property HasMore: Boolean read FHas_more write FHas_more;
    property FirstId: string read FFirst_id write FFirst_id;
    property LastId: string read FLast_id write FLast_id;
    destructor Destroy; override;
  end;

  TAssistantsRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Create an assistant with a model and instructions.
    /// </summary>
    function Create(ParamProc: TProc<TAssistantParams>): TAssistant;
    /// <summary>
    /// Retrieves an assistant.
    /// </summary>
    /// <param name="const AssistantId: string">The ID of the assistant to retrieve.</param>
    function Retrieve(const AssistantId: string): TAssistant;
    /// <summary>
    /// Modifies an assistant.
    /// </summary>
    /// <param name="const AssistantId: string">The ID of the assistant to modify.</param>
    function Modify(const AssistantId: string; ParamProc: TProc<TAssistantParams>): TAssistant;
    /// <summary>
    /// Delete an assistant.
    /// </summary>
    /// <param name="const AssistantId: string">The ID of the assistant to delete.</param>
    function Delete(const AssistantId: string): TDeletionStatus;
    /// <summary>
    /// Retrieves an assistant.
    /// </summary>
    function List(ParamProc: TProc<TAssistantListParams> = nil): TAssistants;
  end;

implementation

{ TAssistant }

destructor TAssistant.Destroy;
var
  Item: TTool;
begin
  for Item in FTools do
    Item.Free;
  FMetadata.Free;
  inherited;
end;

{ TAssistantsRoute }

function TAssistantsRoute.Create(ParamProc: TProc<TAssistantParams>): TAssistant;
begin
  Result := API.Post<TAssistant, TAssistantParams>('assistants', ParamProc);
end;

function TAssistantsRoute.Delete(const AssistantId: string): TDeletionStatus;
begin
  Result := API.Delete<TDeletionStatus>('assistants/' + AssistantId);
end;

function TAssistantsRoute.List(ParamProc: TProc<TAssistantListParams>): TAssistants;
begin
  Result := API.Get<TAssistants, TAssistantListParams>('assistants', ParamProc);
end;

function TAssistantsRoute.Modify(const AssistantId: string; ParamProc: TProc<TAssistantParams>): TAssistant;
begin
  Result := API.Post<TAssistant, TAssistantParams>('assistants/' + AssistantId, ParamProc);
end;

function TAssistantsRoute.Retrieve(const AssistantId: string): TAssistant;
begin
  Result := API.Get<TAssistant>('assistants/' + AssistantId);
end;

{ TAssistantParams }

constructor TAssistantParams.Create;
begin
  inherited;
end;

function TAssistantParams.Description(const Value: string): TAssistantParams;
begin
  Result := TAssistantParams(Add('description', Value));
end;

function TAssistantParams.FileIds(const Value: TArray<string>): TAssistantParams;
begin
  Result := TAssistantParams(Add('file_ids', Value));
end;

function TAssistantParams.Instructions(const Value: string): TAssistantParams;
begin
  Result := TAssistantParams(Add('instructions', Value));
end;

function TAssistantParams.Metadata(const Value: TJSONParam): TAssistantParams;
begin
  Result := TAssistantParams(Add('metadata', Value));
end;

function TAssistantParams.Model(const Value: string): TAssistantParams;
begin
  Result := TAssistantParams(Add('model', Value));
end;

function TAssistantParams.Name(const Value: string): TAssistantParams;
begin
  Result := TAssistantParams(Add('name', Value));
end;

function TAssistantParams.Tools(const Value: TArray<TAssistantTool>): TAssistantParams;
begin
  Result := TAssistantParams(Add('tools', TArray<TJSONParam>(Value)));
end;

{ TAssistants }

destructor TAssistants.Destroy;
var
  Item: TAssistant;
begin
  for Item in FData do
    Item.Free;
  inherited;
end;

{ TAssistantListParams }

function TAssistantListParams.After(const Value: string): TAssistantListParams;
begin
  Result := TAssistantListParams(Add('after', Value));
end;

function TAssistantListParams.Before(const Value: string): TAssistantListParams;
begin
  Result := TAssistantListParams(Add('before', Value));
end;

function TAssistantListParams.Limit(const Value: Integer): TAssistantListParams;
begin
  Result := TAssistantListParams(Add('limit', Value));
end;

function TAssistantListParams.Order(const Value: string): TAssistantListParams;
begin
  Result := TAssistantListParams(Add('order', Value));
end;

{ TTool }

destructor TTool.Destroy;
begin
  FFunction.Free;
  inherited;
end;

{ TToolFunction }

destructor TToolFunction.Destroy;
begin
  FParameters.Free;
  inherited;
end;

{ TAssistantFunctionTool }

function TAssistantFunctionTool.Description(const Value: string): TAssistantFunctionTool;
begin
  Result := TAssistantFunctionTool(Add('description', Value));
end;

function TAssistantFunctionTool.Name(const Value: string): TAssistantFunctionTool;
begin
  Result := TAssistantFunctionTool(Add('name', Value));
end;

function TAssistantFunctionTool.Parameters(const Value: TJSONObject): TAssistantFunctionTool;
begin
  Result := TAssistantFunctionTool(Add('parameters', Value));
end;

end.


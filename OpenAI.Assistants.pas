unit OpenAI.Assistants;

interface

uses
  System.SysUtils, Rest.Json, Rest.Json.Types, REST.JsonReflect, System.JSON,
  OpenAI.API, OpenAI.API.Params, OpenAI.Types, OpenAI.Chat.Functions;

type
  TAssistantTool = class abstract(TJSONParam)
    //Code interpreter tool
    //File search tool
    //Function tool
  end;

  TAssistantCodeInterpreterTool = class(TAssistantTool)
  public
    constructor Create; override;
  end;

  TAssistantFileSearch = class(TJSONParam)
    /// <summary>
    /// The maximum number of results the file search tool should output.
    /// The default is 20 for gpt-4* models and 5 for gpt-3.5-turbo. This number should be between 1 and 50 inclusive.
    /// Note that the file search tool may output fewer than max_num_results results.
    /// See the file search tool documentation for more information.
    /// </summary>
    function MaxNumResults(const Value: Int64): TAssistantFileSearch;
  end;

  TAssistantFileSearchTool = class(TAssistantTool)
  public
    constructor Create; override;
    /// <summary>
    /// Overrides for the file search tool.
    /// </summary>
    function FileSearch(const Value: TAssistantFileSearch): TAssistantFileSearchTool;
  end;

  TAssistantFunctionTool = class(TAssistantTool)
  public
    constructor Create; override;
    function  &Function(const Value: IChatFunction): TAssistantFunctionTool;
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

  TAssistantToolResourcesParams = class(TJSONParam)
    function CodeInterpreter(const FileIds: TArray<string>): TAssistantToolResourcesParams;
    //function FileSearch(const VectorStoreIds: TArray<string>): TAssistantToolResourcesParams;
  end;

  TAssistantResponseFormat = class abstract(TJSONParam)
  private
    /// <summary>
    /// The type of response format being defined
    /// </summary>
    function FormatType(const Value: string): TAssistantResponseFormat;
  end;

  /// <summary>
  /// Default response format. Used to generate text responses.
  /// </summary>
  TAssistantResponseText = class(TAssistantResponseFormat)
  public
    constructor Create; override;
  end;

  /// <summary>
  /// JSON object response format. An older method of generating JSON responses.
  /// Using json_schema is recommended for models that support it.
  /// Note that the model will not generate JSON without a system or user message instructing it to do so.
  /// </summary>
  TAssistantResponseJsonObject = class(TAssistantResponseFormat)
  public
    constructor Create; override;
  end;

  /// <summary>
  /// JSON Schema response format. Used to generate structured JSON responses.
  /// Structured Outputs configuration options, including a JSON Schema.
  /// </summary>
  TAssistantResponseJsonSchema = class(TAssistantResponseFormat)
  private
    FJsonSchema: TJSONObject;
  public
    constructor Create; override;
    /// <summary>
    /// Required. The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TAssistantResponseJsonSchema;
    /// <summary>
    /// A description of what the response format is for, used by the model to determine how to respond in the format.
    /// </summary>
    function Description(const Value: string): TAssistantResponseJsonSchema;
    /// <summary>
    /// The schema for the response format, described as a JSON Schema object.
    /// </summary>
    function Schema(const Value: TJSONObject): TAssistantResponseJsonSchema;
    /// <summary>
    /// Whether to enable strict schema adherence when generating the output.
    /// If set to true, the model will always follow the exact schema defined in the schema field.
    /// Only a subset of JSON Schema is supported when strict is true. To learn more, read the Structured Outputs guide.
    /// </summary>
    function strict(const Value: Boolean = True): TAssistantResponseJsonSchema;
  end;

  TAssistantParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. You can use the List models API to see all of your available models,
    /// or see our Model overview for descriptions of them.
    /// </summary>
    function Model(const Value: string): TAssistantParams;
    /// <summary>
    /// The description of the assistant. The maximum length is 512 characters.
    /// </summary>
    function Description(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// The system instructions that the assistant uses. The maximum length is 32768 characters.
    /// </summary>
    function Instructions(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful
    /// for storing additional information about the object in a structured format.
    /// Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    /// </summary>
    function Metadata(const Value: TJSONParam): TAssistantParams;
    /// <summary>
    /// The name of the assistant. The maximum length is 256 characters.
    /// </summary>
    function Name(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// o-series models only.
    /// Constrains effort on reasoning for reasoning models.
    /// Currently supported values are low, medium, and high. Reducing reasoning
    /// effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </summary>
    function ReasoningEffort(const Value: string): TAssistantParams; overload;
    /// <summary>
    /// Specifies the format that the model must output. Compatible with GPT-4o, GPT-4 Turbo,
    /// and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106.
    ///
    /// Setting to { "type": "json_schema", "json_schema": {...} } enables Structured Outputs which
    /// ensures the model will match your supplied JSON schema. Learn more in the Structured Outputs guide.
    ///
    /// Setting to { "type": "json_object" } enables JSON mode, which ensures the message the model generates is valid JSON.
    ///
    /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a
    /// system or user message. Without this, the model may generate an unending stream of whitespace
    /// until the generation reaches the token limit, resulting in a long-running and seemingly "stuck"
    /// request. Also note that the message content may be partially cut off if finish_reason="length",
    /// which indicates the generation exceeded max_tokens or the conversation exceeded the max
    /// context length.
    /// </summary>
    function ResponseFormat(const Value: TAssistantResponseFormat): TAssistantParams; overload;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output
    /// more random, while lower values like 0.2 will make it more focused and deterministic.
    /// </summary>
    function Temperature(const Value: Extended): TAssistantParams; overload;
    /// <summary>
    /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant.
    /// Tools can be of types code_interpreter, file_search, or function.
    /// </summary>
    function Tools(const Value: TArray<TAssistantTool>): TAssistantParams; overload;
    /// <summary>
    /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool.
    /// For example, the code_interpreter tool requires a list of file IDs,
    /// while the file_search tool requires a list of vector store IDs.
    /// </summary>
    function ToolResources(const Value: TAssistantToolResourcesParams): TAssistantParams; overload;
    /// <summary>
    /// A list of file IDs attached to this assistant. There can be a maximum of 20 files
    /// attached to the assistant. Files are ordered by their creation date in ascending order.
    /// </summary>
    function FileIds(const Value: TArray<string>): TAssistantParams;
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
    /// <param name="AssistantId">The ID of the assistant to retrieve.</param>
    function Retrieve(const AssistantId: string): TAssistant;
    /// <summary>
    /// Modifies an assistant.
    /// </summary>
    /// <param name="AssistantId">The ID of the assistant to modify.</param>
    /// <param name="ParamProc">Params</param>
    function Modify(const AssistantId: string; ParamProc: TProc<TAssistantParams>): TAssistant;
    /// <summary>
    /// Delete an assistant.
    /// </summary>
    /// <param name="AssistantId">The ID of the assistant to delete.</param>
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

function TAssistantParams.ReasoningEffort(const Value: string): TAssistantParams;
begin
  Result := TAssistantParams(Add('reasoning_effort', Value));
end;

function TAssistantParams.ResponseFormat(const Value: TAssistantResponseFormat): TAssistantParams;
begin
  Result := TAssistantParams(Add('response_format', Value));
end;

function TAssistantParams.Temperature(const Value: Extended): TAssistantParams;
begin
  Result := TAssistantParams(Add('temperature', Value));
end;

function TAssistantParams.ToolResources(const Value: TAssistantToolResourcesParams): TAssistantParams;
begin
  Result := TAssistantParams(Add('tool_resources', Value));
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

function TAssistantFunctionTool.&Function(const Value: IChatFunction): TAssistantFunctionTool;
begin
  Result := TAssistantFunctionTool(Add('function', TChatFunction.ToJson(Value)));
end;

constructor TAssistantFunctionTool.Create;
begin
  inherited;
  Add('type', 'function');
end;

{ TAssistantCodeInterpreterTool }

constructor TAssistantCodeInterpreterTool.Create;
begin
  inherited;
  Add('type', 'code_interpreter');
end;

{ TAssistantFileSearchTool }

constructor TAssistantFileSearchTool.Create;
begin
  inherited;
  Add('type', 'file_search');
end;

function TAssistantFileSearchTool.FileSearch(const Value: TAssistantFileSearch): TAssistantFileSearchTool;
begin
  Result := TAssistantFileSearchTool(Add('file_search', Value));
end;

{ TAssistantFileSearch }

function TAssistantFileSearch.MaxNumResults(const Value: Int64): TAssistantFileSearch;
begin
  Result := TAssistantFileSearch(Add('max_num_results', Value));
end;

{ TAssistantToolResourcesParams }

function TAssistantToolResourcesParams.CodeInterpreter(const FileIds: TArray<string>): TAssistantToolResourcesParams;
begin
  Result := TAssistantToolResourcesParams(Add('code_interpreter', TJSONParam.Create.Add('file_ids', FileIds)));
end;

{ TAssistantResponseFormat }

function TAssistantResponseFormat.FormatType(const Value: string): TAssistantResponseFormat;
begin
  Result := TAssistantResponseFormat(Add('type', Value));
end;

{ TAssistantResponseText }

constructor TAssistantResponseText.Create;
begin
  inherited;
  FormatType('text');
end;

{ TAssistantResponseJsonObject }

constructor TAssistantResponseJsonObject.Create;
begin
  inherited;
  FormatType('json_object');
end;

{ TAssistantResponseJsonSchema }

constructor TAssistantResponseJsonSchema.Create;
begin
  inherited;
  FormatType('json_schema');
  FJsonSchema := TJSONObject.Create;
  Add('json_schema', FJsonSchema);
end;

function TAssistantResponseJsonSchema.Description(const Value: string): TAssistantResponseJsonSchema;
begin
  FJsonSchema.AddPair('description', Value);
  Result := TAssistantResponseJsonSchema(Self);
end;

function TAssistantResponseJsonSchema.Name(const Value: string): TAssistantResponseJsonSchema;
begin
  FJsonSchema.AddPair('name', Value);
  Result := TAssistantResponseJsonSchema(Self);
end;

function TAssistantResponseJsonSchema.Schema(const Value: TJSONObject): TAssistantResponseJsonSchema;
begin
  FJsonSchema.AddPair('schema', Value);
  Result := TAssistantResponseJsonSchema(Self);
end;

function TAssistantResponseJsonSchema.strict(const Value: Boolean): TAssistantResponseJsonSchema;
begin
  FJsonSchema.AddPair('strict', Value);
  Result := TAssistantResponseJsonSchema(Self);
end;

end.


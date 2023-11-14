unit OpenAI.Chat;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API, OpenAI.Chat.Functions,
  System.Classes, REST.JsonReflect, System.JSON, OpenAI.Types;

{$SCOPEDENUMS ON}

type
  /// <summary>
  /// Type of message role
  /// </summary>
  TMessageRole = (
    /// <summary>
    /// System message
    /// </summary>
    System,
    /// <summary>
    /// User message
    /// </summary>
    User,
    /// <summary>
    /// Assistant message
    /// </summary>
    Assistant,
    /// <summary>
    /// Func message. For models avaliable functions
    /// </summary>
    Func,
    /// <summary>
    /// Tool message
    /// </summary>
    Tool);

  TMessageRoleHelper = record helper for TMessageRole
    function ToString: string;
    class function FromString(const Value: string): TMessageRole; static;
  end;

  /// <summary>
  /// Finish reason
  /// </summary>
  TFinishReason = (
    /// <summary>
    /// API returned complete model output
    /// </summary>
    Stop,
    /// <summary>
    /// Incomplete model output due to max_tokens parameter or token limit
    /// </summary>
    Length,
    /// <summary>
    /// The model decided to call a function
    /// </summary>
    FunctionCall,
    /// <summary>
    /// Omitted content due to a flag from our content filters
    /// </summary>
    ContentFilter,
    /// <summary>
    /// API response still in progress or incomplete
    /// </summary>
    Null,
    /// <summary>
    /// If the model called a tool
    /// </summary>
    ToolCalls);

  TFinishReasonHelper = record helper for TFinishReason
    function ToString: string;
    class function Create(const Value: string): TFinishReason; static;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
  public
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TFunctionCallType = (None, Auto, Func);

  TFunctionCall = record
  private
    FFuncName: string;
    FType: TFunctionCallType;
  public
    /// <summary>
    /// The model does not call a function, and responds to the end-user
    /// </summary>
    class function None: TFunctionCall; static;
    /// <summary>
    /// The model can pick between an end-user or calling a function
    /// </summary>
    class function Auto: TFunctionCall; static;
    /// <summary>
    /// Forces the model to call that function
    /// </summary>
    class function Func(const Name: string): TFunctionCall; static;
    function ToString: string;
  end;

  TFunctionCallBuild = record
    Name: string;
    /// <summary>
    /// JSON, example '{ \"location\": \"Boston, MA\"}'
    /// </summary>
    Arguments: string;
    // helpers
    class function Create(const Name, Arguments: string): TFunctionCallBuild; static;
  end;

  TChatToolCallBuild = record
    /// <summary>
    /// The ID of the tool call.
    /// </summary>
    Id: string;
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    &Type: string;
    /// <summary>
    /// The function that the model called.
    /// </summary>
    &Function: TFunctionCallBuild;
    // helpers
    class function Create(const Id, &Type: string; &Function: TFunctionCallBuild): TChatToolCallBuild; static;
  end;

  TMessageContentType = (Text, ImageUrl);

  TImageDetail = (
  /// <summary>
  /// By default, the model will use the auto setting which will look at the image input size
  /// and decide if it should use the low or high setting
  /// </summary>
    Auto,
  /// <summary>
  /// Will disable the “high res” model. The model will receive a low-res 512px x 512px version of the image,
  /// and represent the image with a budget of 65 tokens. This allows the API to return faster responses and
  /// consume fewer input tokens for use cases that do not require high detail.
  /// </summary>
    Low,
  /// <summary>
  /// Will enable “high res” mode, which first allows the model to see the low res image and then
  /// creates detailed crops of input images as 512px squares based on the input image size.
  /// Each of the detailed crops uses twice the token budget (65 tokens) for a total of 129 tokens.
  /// </summary>
    High);

  TImageDetailHelper = record helper for TImageDetail
    function ToString: string; inline;
  end;

  TMessageContent = record
    /// <summary>
    /// The type of the content part.
    /// </summary>
    ContentType: TMessageContentType;
    /// <summary>
    /// The text content.
    /// </summary>
    Text: string;
    /// <summary>
    /// Either a URL of the image or the base64 encoded image data.
    /// </summary>
    Url: string;
    /// <summary>
    /// Specifies the detail level of the image. Learn more in the Vision guide.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/vision/low-or-high-fidelity-image-understanding</seealso>
    Detail: TImageDetail;

    class function CreateText(const Text: string): TMessageContent; static;
    class function CreateImage(const Url: string; const Detail: TImageDetail = TImageDetail.Auto): TMessageContent; static;
    class function CreateImageBase64(const Data: TBase64Data; const Detail: TImageDetail = TImageDetail.Auto): TMessageContent; static;
  end;

  TChatMessageBuild = record
  private
    FRole: TMessageRole;
    FContent: string;
    FTool_call_id: string;
    FFunction_call: TFunctionCallBuild;
    FTool_calls: TArray<TChatToolCallBuild>;
    FTag: string;
    FName: string;
    FContents: TArray<TMessageContent>;
  public
    /// <summary>
    /// The role of the messages author. One of system, user, assistant, or function.
    /// </summary>
    property Role: TMessageRole read FRole write FRole;
    /// <summary>
    /// The contents of the message. content is required for all messages, and may be null for assistant messages with function calls.
    /// </summary>
    property Content: string read FContent write FContent;
    /// <summary>
    /// An array of content parts with a defined type, each can be of type text or image_url when passing in images.
    /// You can pass multiple images by adding multiple image_url content parts.
    /// Image input is only supported when using the gpt-4-visual-preview model.
    /// </summary>
    property Contents: TArray<TMessageContent> read FContents write FContents;
    /// <summary>
    /// The name of the author of this message. name is required if role is function,
    /// and it should be the name of the function whose response is in the content.
    /// May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// The name and arguments of a function that should be called, as generated by the model.
    /// </summary>
    property FunctionCall: TFunctionCallBuild read FFunction_call write FFunction_call;
    /// <summary>
    /// Tag - custom field for convenience. Not used in requests!
    /// </summary>
    property Tag: string read FTag write FTag;
    /// <summary>
    /// Tool call that this message is responding to.
    /// </summary>
    property ToolCallId: string read FTool_call_id write FTool_call_id;
    /// <summary>
    /// The tool calls generated by the model, such as function calls.
    /// </summary>
    property ToolCalls: TArray<TChatToolCallBuild> read FTool_calls write FTool_calls;
    // helpers
    class function Create(Role: TMessageRole; const Content: string; const Name: string = ''): TChatMessageBuild; static;
    //Help functions
    /// <summary>
    /// From user
    /// </summary>
    class function User(const Content: string; const Name: string = ''): TChatMessageBuild; overload; static;
    /// <summary>
    /// From user
    /// </summary>
    class function User(const Content: TArray<TMessageContent>; const Name: string = ''): TChatMessageBuild; overload; static;
    /// <summary>
    /// From system
    /// </summary>
    class function System(const Content: string; const Name: string = ''): TChatMessageBuild; static;
    /// <summary>
    /// From assistant
    /// </summary>
    class function Assistant(const Content: string; const Name: string = ''): TChatMessageBuild; static;
    /// <summary>
    /// Function result
    /// </summary>
    class function Func(const Content: string; const Name: string = ''): TChatMessageBuild; static;
    /// <summary>
    /// Tool result
    /// </summary>
    class function Tool(const Content, ToolCallId: string; const Name: string = ''): TChatMessageBuild; static;
    /// <summary>
    /// Assistant want call function
    /// </summary>
    class function AssistantFunc(const Name, Arguments: string): TChatMessageBuild; static;
    /// <summary>
    /// Assistant want call tool
    /// </summary>
    class function AssistantTool(const Content: string; const ToolCalls: TArray<TChatToolCallBuild>): TChatMessageBuild; static;
  end;

  TChatFunctionBuild = record
  private
    FName: string;
    FDescription: string;
    FParameters: string;
  public
    /// <summary>
    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// The description of what the function does.
    /// </summary>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// The parameters the functions accepts, described as a JSON Schema object
    /// </summary>
    property Parameters: string read FParameters write FParameters;
    class function Create(const Name, Description: string; const ParametersJSON: string): TChatFunctionBuild; static;
  end;

  TChatResponseFormat = (Text, JSONObject);

  TChatResponseFormatHelper = record helper for TChatResponseFormat
    function ToString: string; inline;
  end;

  TChatToolParam = class(TJSONParam)
  protected
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    function &Type(const Value: string): TChatToolParam;
  end;

  TChatToolFunctionParam = class(TChatToolParam)
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    function &Function(const Value: IChatFunction): TChatToolFunctionParam;
    constructor Create; reintroduce; overload;
    constructor Create(const Value: IChatFunction); reintroduce; overload;
  end;

  TChatToolChoiceParam = record
  private
    FFuncName: string;
    FType: TFunctionCallType;
  public
    /// <summary>
    /// The model does not call a function, and responds to the end-user
    /// </summary>
    class function None: TChatToolChoiceParam; static;
    /// <summary>
    /// The model can pick between an end-user or calling a function
    /// </summary>
    class function Auto: TChatToolChoiceParam; static;
    /// <summary>
    /// Forces the model to call that function
    /// </summary>
    class function Func(const Name: string): TChatToolChoiceParam; static;
  end;

  TChatParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/models/model-endpoint-compatibility</seealso>
    function Model(const Value: string): TChatParams;
    /// <summary>
    /// A list of messages comprising the conversation so far.
    /// </summary>
    function Messages(const Value: TArray<TChatMessageBuild>): TChatParams; overload;
    /// <summary>
    /// A list of functions the model may generate JSON inputs for.
    /// </summary>
    function Functions(const Value: TArray<IChatFunction>): TChatParams; deprecated;
    /// <summary>
    /// Controls how the model responds to function calls. none means the model does not call a function,
    /// and responds to the end-user. auto means the model can pick between an end-user or calling a function.
    /// Specifying a particular function via {"name": "my_function"} forces the model to call that function.
    /// none is the default when no functions are present. auto is the default if functions are present.
    /// </summary>
    function FunctionCall(const Value: TFunctionCall): TChatParams; deprecated;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic.
    /// We generally recommend altering this or top_p but not both.
    /// </summary>
    function Temperature(const Value: Single = 1): TChatParams;
    /// <summary>
    /// A list of tools the model may call. Currently, only functions are supported as a tool.
    /// Use this to provide a list of functions the model may generate JSON inputs for.
    /// </summary>
    function Tools(const Value: TArray<TChatToolParam>): TChatParams;
    /// <summary>
    /// Controls which (if any) function is called by the model.
    /// "none" means the model will not call a function and instead generates a message.
    /// "auto" means the model can pick between generating a message or calling a function.
    /// Specifying a particular function via {"type: "function", "function": {"name": "my_function"}}
    /// forces the model to call that function.
    /// "none" is the default when no functions are present. "auto" is the default if functions are present.
    /// </summary>
    function ToolChoice(const Value: TChatToolChoiceParam): TChatParams;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the
    /// results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10%
    /// probability mass are considered.
    /// We generally recommend altering this or temperature but not both.
    /// </summary>
    function TopP(const Value: Single = 1): TChatParams;
    /// <summary>
    /// How many chat completion choices to generate for each input message.
    /// </summary>
    function N(const Value: Integer = 1): TChatParams;
    /// <summary>
    /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as
    /// data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
    /// </summary>
    function Stream(const Value: Boolean = True): TChatParams;
    /// <summary>
    /// An object specifying the format that the model must output. Used to enable JSON mode.
    /// Setting to json_object enables JSON mode. This guarantees that the message the
    /// model generates is valid JSON.
    /// Note that your system prompt must still instruct the model to produce JSON,
    /// and to help ensure you don't forget, the API will throw an error if the string JSON
    /// does not appear in your system message. Also note that the message content may be
    /// partial (i.e. cut off) if finish_reason="length", which indicates the generation
    /// exceeded max_tokens or the conversation exceeded the max context length.
    /// Must be one of text or json_object.
    /// </summary>
    function ResponseFormat(const Value: TChatResponseFormat): TChatParams;
    /// <summary>
    /// This feature is in Beta. If specified, our system will make a best effort to sample
    /// deterministically, such that repeated requests with the same seed and parameters
    /// should return the same result. Determinism is not guaranteed, and you should refer
    /// to the system_fingerprint response parameter to monitor changes in the backend.
    /// </summary>
    function Seed(const Value: Integer): TChatParams;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens.
    /// </summary>
    function Stop(const Value: string): TChatParams; overload;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens.
    /// </summary>
    function Stop(const Value: TArray<string>): TChatParams; overload;
    /// <summary>
    /// The maximum number of tokens allowed for the generated answer. By default, the number of
    /// tokens the model can return will be (4096 - prompt tokens).
    /// </summary>
    function MaxTokens(const Value: Integer = 16): TChatParams;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far,
    /// increasing the model's likelihood to talk about new topics.
    /// </summary>
    function PresencePenalty(const Value: Single = 0): TChatParams;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far,
    /// decreasing the model's likelihood to repeat the same line verbatim.
    /// </summary>
    function FrequencyPenalty(const Value: Single = 0): TChatParams;
    /// <summary>
    /// Modify the likelihood of specified tokens appearing in the completion.
    ///
    /// Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias
    /// value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling.
    /// The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection;
    /// values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    /// </summary>
    function LogitBias(const Value: TJSONObject): TChatParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TChatParams;
    constructor Create; override;
  end;

  TChatUsage = class
  private
    FCompletion_tokens: Int64;
    FPrompt_tokens: Int64;
    FTotal_tokens: Int64;
  public
    /// <summary>
    /// Number of tokens in the prompt.
    /// </summary>
    property PromptTokens: Int64 read FPrompt_tokens write FPrompt_tokens;
    /// <summary>
    /// Number of tokens in the generated completion.
    /// </summary>
    property CompletionTokens: Int64 read FCompletion_tokens write FCompletion_tokens;
    /// <summary>
    /// Total number of tokens used in the request (prompt + completion).
    /// </summary>
    property TotalTokens: Int64 read FTotal_tokens write FTotal_tokens;
  end;

  TChatFunctionCall = class
  private
    FName: string;
    FArguments: string;
  public
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// The arguments to call the function with, as generated by the model in JSON format.
    /// Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your
    /// function schema. Validate the arguments in your code before calling your function.
    /// JSON, example '{ \"location\": \"Boston, MA\"}'
    /// </summary>
    property Arguments: string read FArguments write FArguments;
  end;

  TChatToolCall = class
  private
    FId: string;
    FType: string;
    FFunction: TChatFunctionCall;
  public
    /// <summary>
    /// The ID of the tool call.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    property &Type: string read FType write FType;
    /// <summary>
    /// The function that the model called.
    /// </summary>
    property &Function: TChatFunctionCall read FFunction write FFunction;
    destructor Destroy; override;
  end;

  TChatMessage = class
  private
    FRole: string;
    FContent: string;
    FFunction_call: TChatFunctionCall;
    FTool_calls: TArray<TChatToolCall>;
  public
    /// <summary>
    /// The role of the author of this message.
    /// </summary>
    property Role: string read FRole write FRole;
    /// <summary>
    /// The contents of the message.
    /// </summary>
    property Content: string read FContent write FContent;
    /// <summary>
    /// Deprecated and replaced by ToolCalls.
    /// The name and arguments of a function that should be called, as generated by the model.
    /// </summary>
    property FunctionCall: TChatFunctionCall read FFunction_call write FFunction_call;
    /// <summary>
    /// The tool calls generated by the model, such as function calls.
    /// </summary>
    property ToolCalls: TArray<TChatToolCall> read FTool_calls write FTool_calls;
    destructor Destroy; override;
  end;

  TChatChoices = class
  private
    FIndex: Int64;
    FMessage: TChatMessage;
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinish_reason: TFinishReason;
    FDelta: TChatMessage;
  public
    /// <summary>
    /// The index of the choice in the list of choices.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;
    /// <summary>
    /// A chat completion message generated by the model.
    /// </summary>
    property Message: TChatMessage read FMessage write FMessage;
    /// <summary>
    /// A chat completion delta generated by streamed model responses.
    /// </summary>
    property Delta: TChatMessage read FDelta write FDelta;
    /// <summary>
    /// The reason the model stopped generating tokens.
    /// This will be stop if the model hit a natural stop point or a provided stop sequence,
    /// length if the maximum number of tokens specified in the request was reached,
    /// content_filter if content was omitted due to a flag from our content filters,
    /// tool_calls if the model called a tool, or function_call (deprecated) if the model called a function.
    /// </summary>
    property FinishReason: TFinishReason read FFinish_reason write FFinish_reason;
    destructor Destroy; override;
  end;

  TChat = class
  private
    FChoices: TArray<TChatChoices>;
    FCreated: Int64;
    FId: string;
    FObject: string;
    FUsage: TChatUsage;
    FModel: string;
    FSystem_fingerprint: string;
  public
    /// <summary>
    /// A unique identifier for the chat completion.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type, which is always chat.completion.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The Unix timestamp (in seconds) of when the chat completion was created.
    /// </summary>
    property Created: Int64 read FCreated write FCreated;
    /// <summary>
    /// The model used for the chat completion.
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// A list of chat completion choices. Can be more than one if N is greater than 1.
    /// </summary>
    property Choices: TArray<TChatChoices> read FChoices write FChoices;
    /// <summary>
    /// Usage statistics for the completion request.
    /// </summary>
    property Usage: TChatUsage read FUsage write FUsage;
    /// <summary>
    /// This fingerprint represents the backend configuration that the model runs with.
    /// Can be used in conjunction with the seed request parameter to understand when backend
    /// changes have been made that might impact determinism.
    /// </summary>
    property SystemFingerprint: string read FSystem_fingerprint write FSystem_fingerprint;
    destructor Destroy; override;
  end;

  TChatEvent = reference to procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Given a chat conversation, the model will return a chat completion response.
  /// </summary>
  TChatRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a completion for the chat message
    /// </summary>
    /// <exception cref="OpenAIExceptionAPI"></exception>
    /// <exception cref="OpenAIExceptionInvalidRequestError"></exception>
    function Create(ParamProc: TProc<TChatParams>): TChat;
    /// <summary>
    /// Creates a completion for the chat message
    /// </summary>
    /// <remarks>
    /// The Chat object will be nil if all data is received!
    /// </remarks>
    function CreateStream(ParamProc: TProc<TChatParams>; Event: TChatEvent): Boolean;
  end;

implementation

uses
  Rest.Json, System.Rtti;

{ TChatRoute }

function TChatRoute.Create(ParamProc: TProc<TChatParams>): TChat;
begin
  Result := API.Post<TChat, TChatParams>('chat/completions', ParamProc);
end;

function TChatRoute.CreateStream(ParamProc: TProc<TChatParams>; Event: TChatEvent): Boolean;
var
  Response: TStringStream;
  RetPos: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    RetPos := 0;
    Result := API.Post<TChatParams>('chat/completions', ParamProc, Response,
      procedure(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean)
      var
        IsDone: Boolean;
        Data: string;
        Chat: TChat;
        TextBuffer: string;
        Line: string;
        Ret: Integer;
      begin
        try
          TextBuffer := Response.DataString;
        except
          // If there is an encoding error, then the data is definitely not all.
          // This is necessary because the data from the server may not be complete for successful encoding
          on E: EEncodingError do
            Exit;
        end;
        repeat
          Ret := TextBuffer.IndexOf(#10, RetPos);
          if Ret < 0 then
            Continue;
          Line := TextBuffer.Substring(RetPos, Ret - RetPos);
          RetPos := Ret + 1;
          if Line.IsEmpty or Line.StartsWith(#10) then
            Continue;
          Chat := nil;
          Data := Line.Replace('data: ', '').Trim([' ', #13, #10]);
          IsDone := Data = '[DONE]';
          if not IsDone then
          try
            Chat := TJson.JsonToObject<TChat>(Data);
          except
            Chat := nil;
          end;
          try
            Event(Chat, IsDone, AAbort);
          finally
            Chat.Free;
          end;
        until Ret < 0;
      end);
  finally
    Response.Free;
  end;
end;

{ TChat }

destructor TChat.Destroy;
var
  Item: TChatChoices;
begin
  if Assigned(FUsage) then
    FUsage.Free;
  for Item in FChoices do
    Item.Free;
  inherited;
end;

{ TChatParams }

constructor TChatParams.Create;
begin
  inherited;
  Model('gpt-3.5-turbo');
  // Model('gpt-3.5-turbo-0613');
  // Model('gpt-3.5-turbo-16k');
end;

function TChatParams.Functions(const Value: TArray<IChatFunction>): TChatParams;
var
  Items: TJSONArray;
  Item: IChatFunction;
begin
  Items := TJSONArray.Create;
  for Item in Value do
    Items.Add(TChatFunction.ToJson(Item));
  Result := TChatParams(Add('functions', Items));
end;

function TChatParams.LogitBias(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('logit_bias', Value));
end;

function TChatParams.FunctionCall(const Value: TFunctionCall): TChatParams;
begin
  Result := TChatParams(Add('function_call', Value.ToString));
end;

function TChatParams.FrequencyPenalty(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('frequency_penalty', Value));
end;

function TChatParams.MaxTokens(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_tokens', Value));
end;

function TChatParams.Model(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('model', Value));
end;

function TChatParams.N(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('n', Value));
end;

function TChatParams.PresencePenalty(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('presence_penalty', Value));
end;

function TChatParams.ResponseFormat(const Value: TChatResponseFormat): TChatParams;
begin
  var VJO := TJSONParam.Create;
  VJO.Add('type', Value.ToString);
  Result := TChatParams(Add('response_format', VJO));
end;

function TChatParams.Messages(const Value: TArray<TChatMessageBuild>): TChatParams;
var
  Item: TChatMessageBuild;
  ToolItem: TChatToolCallBuild;
  JSON: TJSONObject;
  Items, Tools: TJSONArray;
  FuncData, ToolData: TJSONObject;
begin
  Items := TJSONArray.Create;
  try
    for Item in Value do
    begin
      JSON := TJSONObject.Create;

      //role
      JSON.AddPair('role', Item.Role.ToString);

      //content
      if not Item.Content.IsEmpty then
        JSON.AddPair('content', Item.Content)
      else if Length(Item.Contents) > 0 then
      begin
        var Contents := TJSONArray.Create;
        JSON.AddPair('content', Contents);
        for var Content in Item.Contents do
        begin
          var ContentItem := TJSONObject.Create;
          Contents.Add(ContentItem);
          case Content.ContentType of
            TMessageContentType.Text:
              begin
                ContentItem.AddPair('type', 'text');
                ContentItem.AddPair('text', Content.Text);
              end;
            TMessageContentType.ImageUrl:
              begin
                ContentItem.AddPair('type', 'image_url');
                var ImageUrl := TJSONObject.Create;
                ContentItem.AddPair('image_url', ImageUrl);
                ImageUrl.AddPair('url', Content.Url);
                if Content.Detail <> TImageDetail.Auto then
                  ImageUrl.AddPair('detail', Content.Detail.ToString);
              end;
          end;
        end;
      end;

      //name
      if not Item.Name.IsEmpty then
        JSON.AddPair('name', Item.Name);

      //function call
      if not Item.FunctionCall.Name.IsEmpty then
      begin
        FuncData := TJSONObject.Create;
        JSON.AddPair('function_call', FuncData);
        FuncData.AddPair('name', Item.FunctionCall.Name);
        FuncData.AddPair('arguments', Item.FunctionCall.Arguments);
      end;

      // tool calls
      if Length(Item.ToolCalls) > 0 then
      begin
        Tools := TJSONArray.Create;
        JSON.AddPair('tool_calls', Tools);
        for ToolItem in Item.ToolCalls do
        begin
          ToolData := TJSONObject.Create;
          Tools.Add(ToolData);
          ToolData.AddPair('id', ToolItem.Id);
          ToolData.AddPair('type', ToolItem.&Type);
          if not ToolItem.&Function.Name.IsEmpty then
          begin
            FuncData := TJSONObject.Create;
            ToolData.AddPair('function', FuncData);
            FuncData.AddPair('name', ToolItem.&Function.Name);
            FuncData.AddPair('arguments', ToolItem.&Function.Arguments);
          end;
        end;
      end;

      Items.Add(JSON);
    end;
  except
    Items.Free;
    raise;
  end;
  Result := TChatParams(Add('messages', Items));
end;

function TChatParams.Seed(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('seed', Value));
end;

function TChatParams.Stop(const Value: TArray<string>): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stop(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stream(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('stream', Value));
end;

function TChatParams.Temperature(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('temperature', Value));
end;

function TChatParams.ToolChoice(const Value: TChatToolChoiceParam): TChatParams;
begin
  case Value.FType of
    TFunctionCallType.None:
      Result := TChatParams(Add('tool_choice', 'none'));
    TFunctionCallType.Auto:
      Result := TChatParams(Add('tool_choice', 'auto'));
    TFunctionCallType.Func:
      begin
        var VJO := TJSONParam.Create;
        var VJF := TJSONParam.Create;
        VJO.Add('type', 'function');
        VJF.Add('name', Value.FFuncName);
        VJO.Add('function', VJF);
        Result := TChatParams(Add('tool_choice', VJO));
      end;
  else
    Result := Self;
  end;
end;

function TChatParams.Tools(const Value: TArray<TChatToolParam>): TChatParams;
begin
  Result := TChatParams(Add('tools', TArray<TJSONParam>(Value)));
end;

function TChatParams.TopP(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('top_p', Value));
end;

function TChatParams.User(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('user', Value));
end;

{ TChatMessageBuild }

class function TChatMessageBuild.Assistant(const Content: string; const Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Assistant;
  Result.FContent := Content;
  Result.FName := Name;
end;

class function TChatMessageBuild.AssistantFunc(const Name, Arguments: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Assistant;
  Result.FContent := 'null';
  Result.FFunction_call.Name := Name;
  Result.FFunction_call.Arguments := Arguments;
end;

class function TChatMessageBuild.AssistantTool(const Content: string; const ToolCalls: TArray<TChatToolCallBuild>): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Assistant;
  if Content.IsEmpty then
    Result.FContent := 'null'
  else
    Result.FContent := Content;
  Result.FTool_calls := ToolCalls;
end;

class function TChatMessageBuild.Create(Role: TMessageRole; const Content: string; const Name: string): TChatMessageBuild;
begin
  Result.FRole := Role;
  Result.FContent := Content;
  Result.FName := Name;
end;

class function TChatMessageBuild.Func(const Content, Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Func;
  Result.FContent := Content;
  Result.FName := Name;
end;

class function TChatMessageBuild.System(const Content: string; const Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.System;
  Result.FContent := Content;
  Result.FName := Name;
end;

class function TChatMessageBuild.Tool(const Content, ToolCallId, Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Tool;
  Result.FContent := Content;
  Result.FName := Name;
  Result.FTool_call_id := ToolCallId;
end;

class function TChatMessageBuild.User(const Content: TArray<TMessageContent>; const Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.User;
  Result.FContents := Content;
  Result.FName := Name;
end;

class function TChatMessageBuild.User(const Content: string; const Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.User;
  Result.FContent := Content;
  Result.FName := Name;
end;

{ TMessageRoleHelper }

class function TMessageRoleHelper.FromString(const Value: string): TMessageRole;
begin
  if Value = 'system' then
    Exit(TMessageRole.System)
  else if Value = 'user' then
    Exit(TMessageRole.User)
  else if Value = 'assistant' then
    Exit(TMessageRole.Assistant)
  else if Value = 'tool' then
    Exit(TMessageRole.Tool)
  else if Value = 'function' then
    Exit(TMessageRole.Func)
  else
    Result := TMessageRole.User;
end;

function TMessageRoleHelper.ToString: string;
begin
  case Self of
    TMessageRole.System:
      Result := 'system';
    TMessageRole.User:
      Result := 'user';
    TMessageRole.Assistant:
      Result := 'assistant';
    TMessageRole.Func:
      Result := 'function';
    TMessageRole.Tool:
      Result := 'tool';
  end;
end;

{ TChatChoices }

destructor TChatChoices.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ TChatFonctionBuild }

class function TChatFunctionBuild.Create(const Name, Description: string; const ParametersJSON: string): TChatFunctionBuild;
begin
  Result.FName := Name;
  Result.FDescription := Description;
  Result.FParameters := ParametersJSON;
end;

{ TChatMessage }

destructor TChatMessage.Destroy;
var
  Item: TChatToolCall;
begin
  if Assigned(FFunction_call) then
    FFunction_call.Free;
  for Item in FTool_calls do
    Item.Free;
  inherited;
end;

{ TFunctionCall }

class function TFunctionCall.Auto: TFunctionCall;
begin
  Result.FType := TFunctionCallType.Auto;
end;

class function TFunctionCall.Func(const Name: string): TFunctionCall;
begin
  Result.FType := TFunctionCallType.Func;
  Result.FFuncName := Name;
end;

class function TFunctionCall.None: TFunctionCall;
begin
  Result.FType := TFunctionCallType.None;
end;

function TFunctionCall.ToString: string;
var
  JSON: TJSONObject;
begin
  case FType of
    TFunctionCallType.None:
      Result := 'none';
    TFunctionCallType.Auto:
      Result := 'auto';
    TFunctionCallType.Func:
      begin
        JSON := TJSONObject.Create(TJSONPair.Create('name', FFuncName));
        try
          Result := JSON.ToJSON;
        finally
          JSON.Free;
        end;
      end;
  end;
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFinishReason>.ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFinishReason.Create(Arg)));
end;

{ TFinishReasonHelper }

class function TFinishReasonHelper.Create(const Value: string): TFinishReason;
begin
  if Value = 'stop' then
    Exit(TFinishReason.Stop)
  else if Value = 'length' then
    Exit(TFinishReason.Length)
  else if Value = 'function_call' then
    Exit(TFinishReason.FunctionCall)
  else if Value = 'content_filter' then
    Exit(TFinishReason.ContentFilter)
  else if Value = 'null' then
    Exit(TFinishReason.ToolCalls)
  else if Value = 'tool_calls ' then
    Exit(TFinishReason.Null);
  Result := TFinishReason.Stop;
end;

function TFinishReasonHelper.ToString: string;
begin
  case Self of
    TFinishReason.Stop:
      Exit('stop');
    TFinishReason.Length:
      Exit('length');
    TFinishReason.FunctionCall:
      Exit('function_call');
    TFinishReason.ContentFilter:
      Exit('content_filter');
    TFinishReason.Null:
      Exit('null');
    TFinishReason.ToolCalls:
      Exit('tool_calls ');
  end;
end;

{ TChatResponseFormatHelper }

function TChatResponseFormatHelper.ToString: string;
begin
  case Self of
    TChatResponseFormat.Text:
      Exit('text');
    TChatResponseFormat.JSONObject:
      Exit('json_object');
  end;
end;

{ TChatToolParam }

function TChatToolParam.&Type(const Value: string): TChatToolParam;
begin
  Result := TChatToolParam(Add('type', Value));
end;

{ TChatToolFunctionParam }

constructor TChatToolFunctionParam.Create;
begin
  inherited;
  &Type('function');
end;

constructor TChatToolFunctionParam.Create(const Value: IChatFunction);
begin
  Create;
  &Function(Value);
end;

function TChatToolFunctionParam.&Function(const Value: IChatFunction): TChatToolFunctionParam;
begin
  Result := TChatToolFunctionParam(Add('function', TChatFunction.ToJson(Value)));
end;

{ TChatToolChoiceParam }

class function TChatToolChoiceParam.Auto: TChatToolChoiceParam;
begin
  Result.FType := TFunctionCallType.Auto;
end;

class function TChatToolChoiceParam.Func(const Name: string): TChatToolChoiceParam;
begin
  Result.FType := TFunctionCallType.Func;
  Result.FFuncName := Name;
end;

class function TChatToolChoiceParam.None: TChatToolChoiceParam;
begin
  Result.FType := TFunctionCallType.None;
end;

{ TChatToolCall }

destructor TChatToolCall.Destroy;
begin
  FFunction.Free;
  inherited;
end;

{ TChatToolCallBuild }

class function TChatToolCallBuild.Create(const Id, &Type: string; &Function: TFunctionCallBuild): TChatToolCallBuild;
begin
  Result.Id := Id;
  Result.&Type := &Type;
  Result.&Function := &Function;
end;

{ TFunctionCallBuild }

class function TFunctionCallBuild.Create(const Name, Arguments: string): TFunctionCallBuild;
begin
  Result.Name := Name;
  Result.Arguments := Arguments;
end;

{ TMessageContent }

class function TMessageContent.CreateImage(const Url: string; const Detail: TImageDetail): TMessageContent;
begin
  Result.ContentType := TMessageContentType.ImageUrl;
  Result.Url := Url;
  Result.Detail := Detail;
end;

class function TMessageContent.CreateImageBase64(const Data: TBase64Data; const Detail: TImageDetail): TMessageContent;
begin
  Result.ContentType := TMessageContentType.ImageUrl;
  Result.Url := Data.ToString;
  Result.Detail := Detail;
end;

class function TMessageContent.CreateText(const Text: string): TMessageContent;
begin
  Result.ContentType := TMessageContentType.Text;
  Result.Text := Text;
end;

{ TImageDetailHelper }

function TImageDetailHelper.ToString: string;
begin
  case Self of
    TImageDetail.Auto:
      Exit('auto');
    TImageDetail.Low:
      Exit('low');
    TImageDetail.High:
      Exit('high');
  end;
end;

end.


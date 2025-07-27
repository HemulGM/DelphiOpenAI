﻿unit OpenAI.Chat;

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
    /// Developer-provided instructions that the model should follow,
    /// regardless of messages sent by the user. With o1 models and newer,
    /// use developer messages for this purpose instead.
    /// </summary>
    System,
    /// <summary>
    /// Messages sent by an end user, containing prompts or additional context information.
    /// </summary>
    User,
    /// <summary>
    /// Messages sent by the model in response to user messages.
    /// </summary>
    Assistant,
    /// <summary>
    /// Depricated. Func message. For models avaliable functions.
    /// </summary>
    Func,
    /// <summary>
    /// Tool message
    /// </summary>
    Tool,
    /// <summary>
    /// Developer-provided instructions that the model should follow,
    /// regardless of messages sent by the user. With o1 models and newer,
    /// developer messages replace the previous system messages.
    /// </summary>
    Developer);

  TMessageRoleHelper = record helper for TMessageRole
    function ToString: string;
    class function FromString(const Value: string): TMessageRole; static;
  end;

  TModality = (Text, Audio);

  TModalityHelper = record helper for TModality
    function ToString: string;
  end;

  TModalities = set of TModality;

  TModalitiesHelper = record helper for TModalities
    function ToStringArray: TArray<string>;
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

  TReasoningEffort = (Low, Medium, High);

  TReasoningEffortHelper = record helper for TReasoningEffort
    function ToString: string;
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
    //helpers
    class function CreateText(const Text: string): TMessageContent; static;
    /// <summary>
    /// The Chat Completions API, unlike the Assistants API, is not stateful.
    /// That means you have to manage the messages (including images) you pass to the model yourself.
    /// If you want to pass the same image to the model multiple times, you will have to pass the image each time
    /// you make a request to the API.
    ///
    /// For long running conversations, we suggest passing images via URL's instead of base64.
    /// The latency of the model can also be improved by downsizing your images ahead of time to be less than
    /// the maximum size they are expected them to be. For low res mode, we expect a 512px x 512px image.
    /// For high rest mode, the short side of the image should be less than 768px and the long side should be less
    /// than 2,000px.
    /// </summary>
    class function CreateImage(const Url: string; const Detail: TImageDetail = TImageDetail.Auto): TMessageContent; overload; static;
    /// <summary>
    /// The Chat Completions API, unlike the Assistants API, is not stateful.
    /// That means you have to manage the messages (including images) you pass to the model yourself.
    /// If you want to pass the same image to the model multiple times, you will have to pass the image each time
    /// you make a request to the API.
    ///
    /// For long running conversations, we suggest passing images via URL's instead of base64.
    /// The latency of the model can also be improved by downsizing your images ahead of time to be less than
    /// the maximum size they are expected them to be. For low res mode, we expect a 512px x 512px image.
    /// For high rest mode, the short side of the image should be less than 768px and the long side should be less
    /// than 2,000px.
    /// </summary>
    class function CreateImage(const Data: TBase64Data; const Detail: TImageDetail = TImageDetail.Auto): TMessageContent; overload; static;
    /// <summary>
    /// The Chat Completions API, unlike the Assistants API, is not stateful.
    /// That means you have to manage the messages (including images) you pass to the model yourself.
    /// If you want to pass the same image to the model multiple times, you will have to pass the image each time
    /// you make a request to the API.
    ///
    /// For long running conversations, we suggest passing images via URL's instead of base64.
    /// The latency of the model can also be improved by downsizing your images ahead of time to be less than
    /// the maximum size they are expected them to be. For low res mode, we expect a 512px x 512px image.
    /// For high rest mode, the short side of the image should be less than 768px and the long side should be less
    /// than 2,000px.
    /// </summary>
    class function CreateImage(const Data: TStream; const FileContentType: string; const Detail: TImageDetail = TImageDetail.Auto): TMessageContent; overload; static;
  end;

  TMessageContentBase = class abstract(TJSONParam)
  protected
    /// <summary>
    /// The type of the content part.
    /// </summary>
    function ContentType(const Value: string): TMessageContentBase; virtual;
  end;

  /// <summary>
  /// Text content part
  /// </summary>
  TMessageContentText = class(TMessageContentBase)
  public
    /// <summary>
    /// The text content.
    /// </summary>
    function Text(const Value: string): TMessageContentText; virtual;
    constructor Create; override;
  end;

  /// <summary>
  /// Image content part
  /// </summary>
  TMessageContentImage = class(TMessageContentBase)
  public
    /// <summary>
    /// The image content.
    /// <param name="Url">Either a URL of the image or the base64 encoded image data.</param>
    /// <param name="Detail">Specifies the detail level of the image. Learn more in the Vision guide.</param>
    /// </summary>
    function ImageUrl(const Url: string; const Detail: string = ''): TMessageContentImage; virtual;
    constructor Create; override;
  end;

  /// <summary>
  /// Audio content part
  /// </summary>
  TMessageContentAudio = class(TMessageContentBase)
  public
    /// <summary>
    /// The audio content.
    /// <param name="Data">Base64 encoded audio data.</param>
    /// <param name="Format">The format of the encoded audio data. Currently supports "wav" and "mp3".</param>
    /// </summary>
    function InputAudio(const Data, Format: string): TMessageContentAudio; virtual;
    constructor Create; override;
  end;

  /// <summary>
  /// File content part
  /// </summary>
  TMessageContentFile = class(TMessageContentBase)
  public
    /// <summary>
    /// The base64 encoded file data, used when passing the file to the model as a string.
    /// </summary>
    function FileData(const Value: string): TMessageContentFile; virtual;
    /// <summary>
    /// The ID of an uploaded file to use as input.
    /// </summary>
    function FileId(const Value: string): TMessageContentFile; virtual;
    /// <summary>
    /// The name of the file, used when passing the file to the model as a string.
    /// </summary>
    function FileName(const Value: string): TMessageContentFile; virtual;
    constructor Create; override;
  end;

  /// <summary>
  /// Refusal content part
  /// </summary>
  TMessageContentRefusal = class(TMessageContentBase)
  public
    /// <summary>
    /// The refusal message generated by the model.
    /// </summary>
    function Refusal(const Value: string): TMessageContentFile; virtual;
    constructor Create; override;
  end;

  TChatMessageDeveloper = class;

  TChatMessageSystem = class;

  TChatMessageUser = class;

  TChatMessageAssistant = class;

  TChatMessageTool = class;

  TChatMessageFunction = class;

  TChatMessageBase = class abstract(TJSONParam)
  protected
    /// <summary>
    /// The role of the messages author.
    /// </summary>
    function Role(const Value: string): TChatMessageBase; virtual;
  public
    /// <summary>
    /// Developer-provided instructions that the model should follow, regardless of messages sent by the user.
    /// With o1 models and newer, developer messages replace the previous system messages.
    /// </summary>
    function Developer: TChatMessageDeveloper;
    /// <summary>
    /// Developer-provided instructions that the model should follow, regardless of messages sent by the user.
    /// With o1 models and newer, use developer messages for this purpose instead.
    /// </summary>
    function System: TChatMessageSystem;
    /// <summary>
    /// Messages sent by an end user, containing prompts or additional context information.
    /// </summary>
    function User: TChatMessageUser;
    /// <summary>
    /// Messages sent by the model in response to user messages.
    /// </summary>
    function Assistant: TChatMessageAssistant;
    /// <summary>
    /// Tool message
    /// </summary>
    function Tool: TChatMessageTool;
    /// <summary>
    /// Deprecated. Function message
    /// </summary>
    function  &Function: TChatMessageFunction; deprecated;
  end;

  /// <summary>
  /// Developer-provided instructions that the model should follow, regardless of messages sent by the user.
  /// With o1 models and newer, developer messages replace the previous system messages.
  /// </summary>
  TChatMessageDeveloper = class(TChatMessageBase)
  public
    /// <summary>
    /// The contents of the developer message.
    /// </summary>
    function Content(const Value: string): TChatMessageDeveloper; overload;
    /// <summary>
    /// An array of content parts with a defined type. Supported options differ based on the model being used to generate the response. Can contain text, image, or audio inputs.
    /// </summary>
    function Content(const Value: TArray<TMessageContentBase>): TChatMessageDeveloper; overload;
    /// <summary>
    /// An optional name for the participant. Provides the model information to differentiate between participants of the same role.
    /// </summary>
    function Name(const Value: string): TChatMessageDeveloper;
    constructor Create; override;
  end;

  /// <summary>
  /// Developer-provided instructions that the model should follow, regardless of messages sent by the user.
  /// With o1 models and newer, use developer messages for this purpose instead.
  /// </summary>
  TChatMessageSystem = class(TChatMessageBase)
  public
    /// <summary>
    /// The contents of the system message.
    /// </summary>
    function Content(const Value: string): TChatMessageSystem; overload;
    /// <summary>
    /// An array of content parts with a defined type. Supported options differ based on the model being used to generate the response. Can contain text, image, or audio inputs.
    /// </summary>
    function Content(const Value: TArray<TMessageContentBase>): TChatMessageSystem; overload;
    /// <summary>
    /// An optional name for the participant. Provides the model information to differentiate between participants of the same role.
    /// </summary>
    function Name(const Value: string): TChatMessageSystem;
    constructor Create; override;
  end;

  /// <summary>
  /// Messages sent by an end user, containing prompts or additional context information.
  /// </summary>
  TChatMessageUser = class(TChatMessageBase)
  public
    /// <summary>
    /// The text contents of the message.
    /// </summary>
    function Content(const Value: string): TChatMessageUser; overload;
    /// <summary>
    /// An array of content parts with a defined type. Supported options differ based on the model being used to generate the response. Can contain text, image, or audio inputs.
    /// </summary>
    function Content(const Value: TArray<TMessageContentBase>): TChatMessageUser; overload;
    /// <summary>
    /// An optional name for the participant. Provides the model information to differentiate between participants of the same role.
    /// </summary>
    function Name(const Value: string): TChatMessageUser;
    constructor Create; override;
  end;

  TToolCall = class abstract(TJSONParam)
  protected
    function  &Type(const Value: string): TToolCall;
  end;

  TToolCallFunction = class(TToolCall)
  public
    /// <summary>
    /// The function that the model called.
    /// <param name="Name">The name of the function to call.</param>
    /// <param name="Arguments">The arguments to call the function with, as generated by the model in JSON format.
    /// Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema.
    /// Validate the arguments in your code before calling your function.</param>
    /// </summary>
    function  &Function(const Name, Arguments: string): TToolCallFunction;
    /// <summary>
    /// The ID of the tool call.
    /// </summary>
    function Id(const Value: string): TToolCallFunction;
    constructor Create; override;
  end;

  /// <summary>
  /// Messages sent by the model in response to user messages.
  /// </summary>
  TChatMessageAssistant = class(TChatMessageBase)
  public
    /// <summary>
    /// Data about a previous audio response from the model. Learn more.
    /// <param name="Id">Unique identifier for a previous audio response from the model.</param>
    /// </summary>
    function Audio(const Id: string): TChatMessageAssistant; overload;
    /// <summary>
    /// The contents of the assistant message. Required unless tool_calls or function_call is specified.
    /// </summary>
    function Content(const Value: string): TChatMessageAssistant; overload;
    /// <summary>
    /// Required unless tool_calls or function_call is specified.
    /// An array of content parts with a defined type. Can be one or more of type text, or exactly one of type refusal.
    /// </summary>
    function Content(const Value: TArray<TMessageContentBase>): TChatMessageAssistant; overload;
    /// <summary>
    /// Deprecated and replaced by tool_calls. The name and arguments of a function that should be called, as generated by the model.
    /// <param name="Name">The name of the function to call.</param>
    /// <param name="Arguments">The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.</param>
    /// </summary>
    function FunctionCall(const Name, Arguments: string): TChatMessageAssistant; deprecated;
    /// <summary>
    /// An optional name for the participant. Provides the model information to differentiate between participants of the same role.
    /// </summary>
    function Name(const Value: string): TChatMessageAssistant;
    /// <summary>
    /// The refusal message by the assistant.
    /// </summary>
    function Refusal(const Value: string): TChatMessageAssistant;
    /// <summary>
    /// The tool calls generated by the model, such as function calls.
    /// </summary>
    function ToolCalls(const Value: TArray<TToolCall>): TChatMessageAssistant;
    constructor Create; override;
  end;

  /// <summary>
  /// Tool message
  /// </summary>
  TChatMessageTool = class(TChatMessageBase)
  public
    /// <summary>
    /// The contents of the tool message.
    /// </summary>
    function Content(const Value: string): TChatMessageTool; overload;
    /// <summary>
    /// An array of content parts with a defined type. Supported options differ based on the model being used to generate the response. Can contain text, image, or audio inputs.
    /// </summary>
    function Content(const Value: TArray<TMessageContentBase>): TChatMessageTool; overload;
    /// <summary>
    /// Tool call that this message is responding to.
    /// </summary>
    function ToolCallId(const Value: string): TChatMessageTool;
    constructor Create; override;
  end;

  /// <summary>
  /// Deprecated. Function message
  /// </summary>
  TChatMessageFunction = class(TChatMessageBase)
  public
    /// <summary>
    /// The contents of the function message.
    /// </summary>
    function Content(const Value: string): TChatMessageFunction; overload; deprecated;
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    function Name(const Value: string): TChatMessageFunction; deprecated;
    constructor Create; override; deprecated;
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
    FRefusal: string;
    FAudioId: string;
  public
    /// <summary>
    /// The contents of the message. content is required for all messages, and may be null
    /// for assistant messages with function calls.
    /// </summary>
    property Content: string read FContent write FContent;
    /// <summary>
    /// The role of the messages author. One of TMessageRole.
    /// </summary>
    property Role: TMessageRole read FRole write FRole;
    /// <summary>
    /// Data about a previous audio response from the model.
    /// Unique identifier for a previous audio response from the model.
    /// </summary>
    property AudioId: string read FAudioId write FAudioId;
    /// <summary>
    /// The name of the author of this message. "name" is required if role is "function",
    /// and it should be the name of the function whose response is in the content.
    /// May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// An array of content parts with a defined type, each can be of type "text" or "image_url"
    /// when passing in images.
    /// You can pass multiple images by adding multiple "image_url" content parts.
    /// Image input is only supported when using the "gpt-4-vision-preview" model.
    /// </summary>
    property Contents: TArray<TMessageContent> read FContents write FContents;
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
    /// <summary>
    /// The refusal message by the assistant.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
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
    /// From developer
    /// </summary>
    class function Developer(const Content: string; const Name: string = ''): TChatMessageBuild; overload; static;
    /// <summary>
    /// From developer
    /// </summary>
    class function Developer(const Content: TArray<TMessageContent>; const Name: string = ''): TChatMessageBuild; overload; static;
    /// <summary>
    /// From assistant
    /// </summary>
    class function Assistant(const Content: string; const Name: string = ''): TChatMessageBuild; overload; static;
    /// <summary>
    /// From assistant
    /// </summary>
    class function Assistant(const Content: TArray<TMessageContent>; const Name: string = ''): TChatMessageBuild; overload; static;
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
    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
    /// with a maximum length of 64.
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

  TChatResponseFormat = (Text, JSONObject, JSONSchema);

  TChatResponseFormatHelper = record helper for TChatResponseFormat
    function ToString: string; inline;
  end;

  TChatToolParam = class(TJSONParam)
  protected
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    function  &Type(const Value: string): TChatToolParam;
  end;

  TChatToolFunctionParam = class(TChatToolParam)
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    function  &Function(const Value: IChatFunction): TChatToolFunctionParam;
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

  TJSONSchemaFormat = class(TJSONParam)
    /// <summary>
    /// Optional
    /// A description of what the response format is for, used by the model to determine how to respond in the format.
    /// </summary>
    function Description(const Value: string): TJSONSchemaFormat;
    /// <summary>
    /// The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TJSONSchemaFormat;
    /// <summary>
    /// Optional
    /// The schema for the response format, described as a JSON Schema object.
    /// </summary>
    function Schema(const Value: TJSONValue): TJSONSchemaFormat;
    /// <summary>
    /// Optional
    /// Whether to enable strict schema adherence when generating the output.
    /// If set to true, the model will always follow the exact schema defined in the schema field.
    /// Only a subset of JSON Schema is supported when strict is true. To learn more, read the Structured Outputs guide.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/structured-outputs</seealso>
    function strict(const Value: Boolean = True): TJSONSchemaFormat;
  end;

  TChatParams = class(TJSONParam)
    /// <summary>
    /// A list of messages comprising the conversation so far. Depending on the model you use,
    /// different message types (modalities) are supported, like text, images, and audio.
    /// </summary>
    function Messages(const Value: TArray<TChatMessageBuild>): TChatParams; overload;
    /// <summary>
    /// A list of messages comprising the conversation so far. Depending on the model you use,
    /// different message types (modalities) are supported, like text, images, and audio.
    /// </summary>
    function Messages(const Value: TArray<TChatMessageBase>): TChatParams; overload;
    /// <summary>
    /// ID of the model to use. See the model endpoint compatibility table for details on which models
    /// work with the Chat API.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/models/model-endpoint-compatibility</seealso>
    function Model(const Value: string): TChatParams;
    /// <summary>
    /// A list of functions the model may generate JSON inputs for.
    /// </summary>
    function Functions(const Value: TArray<IChatFunction>): TChatParams; deprecated 'Use Tools';
    /// <summary>
    /// Controls how the model responds to function calls. none means the model does not call a function,
    /// and responds to the end-user. auto means the model can pick between an end-user or calling a function.
    /// Specifying a particular function via {"name": "my_function"} forces the model to call that function.
    /// none is the default when no functions are present. auto is the default if functions are present.
    /// </summary>
    function FunctionCall(const Value: TFunctionCall): TChatParams; deprecated 'Use ToolChoice';
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic.
    /// We generally recommend altering this or top_p but not both.
    /// </summary>
    function Temperature(const Value: Single): TChatParams;
    /// <summary>
    /// A list of tools the model may call. Currently, only functions are supported as a tool.
    /// Use this to provide a list of functions the model may generate JSON inputs for.
    /// A max of 128 functions are supported.
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
    /// Whether to enable parallel function calling during tool use.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/function-calling/parallel-function-calling</seealso>
    function ParallelToolCalls(const Value: Boolean): TChatParams;
    /// <summary>
    /// Static predicted output content, such as the content of a text file that is being regenerated.
    /// Configuration for a Predicted Output, which can greatly improve response times
    /// when large parts of the model response are known ahead of time.
    /// This is most common when you are regenerating a file with only minor changes to most of the content.
    /// </summary>
    function Prediction(const Value: TArray<TMessageContentBase>): TChatParams;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the
    /// results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10%
    /// probability mass are considered.
    /// We generally recommend altering this or temperature but not both.
    /// </summary>
    function TopP(const Value: Single): TChatParams;
    /// <summary>
    /// How many chat completion choices to generate for each input message.
    /// Note that you will be charged based on the number of generated tokens across all of the choices.
    /// Keep n as 1 to minimize costs.
    /// </summary>
    function N(const Value: Integer): TChatParams;
    /// <summary>
    /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as
    /// data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
    /// </summary>
    function Stream(const Value: Boolean = True): TChatParams;
    /// <summary>
    /// Options for streaming response. Only set this when you set stream: true.
    /// </summary>
    /// <param name="IncludeUsage">If set, an additional chunk will be streamed before the data:
    /// [DONE] message. The usage field on this chunk shows the token usage statistics for the entire request,
    /// and the choices field will always be an empty array. All other chunks will also include a usage field,
    /// but with a null value.
    /// </param>
    function StreamOptions(const IncludeUsage: Boolean = True): TChatParams;
    /// <summary>
    /// An object specifying the format that the model must output.
    /// Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
    /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model
    /// generates is valid JSON.
    /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a
    /// system or user message. Without this, the model may generate an unending stream of whitespace until
    /// the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request.
    /// Also note that the message content may be partially cut off if finish_reason="length",
    /// which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
    /// </summary>
    function ResponseFormat(const Value: TChatResponseFormat; SchemaFormat: TJSONSchemaFormat = nil): TChatParams;
    /// <summary>
    /// This feature is in Beta. If specified, our system will make a best effort to sample
    /// deterministically, such that repeated requests with the same seed and parameters
    /// should return the same result. Determinism is not guaranteed, and you should refer
    /// to the system_fingerprint response parameter to monitor changes in the backend.
    /// </summary>
    function Seed(const Value: Integer): TChatParams;
    /// <summary>
    /// Specifies the latency tier to use for processing the request. This parameter is
    /// relevant for customers subscribed to the scale tier service:
    /// <para> - If set to 'auto', and the Project is Scale tier enabled, the system will
    /// utilize scale tier credits until they are exhausted. </para>
    /// <para> - If set to 'auto', and the Project is not Scale tier enabled, the request
    /// will be processed using the default service tier with a lower uptime SLA and no latency guarentee. </para>
    /// <para> - If set to 'default', the request will be processed using the default service tier
    /// with a lower uptime SLA and no latency guarentee. </para>
    /// <para> - When not set, the default behavior is 'auto'. </para>
    /// <para> When this parameter is set, the response body will include the <b>service_tier</b> utilized. </para>
    /// </summary>
    function ServiceTier(const Value: string): TChatParams; overload;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    /// </summary>
    function Stop(const Value: string): TChatParams; overload;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    /// </summary>
    function Stop(const Value: TArray<string>): TChatParams; overload;
    /// <summary>
    /// Whether or not to store the output of this chat completion request for use in our model distillation or evals products.
    /// </summary>
    function Store(const Value: Boolean = True): TChatParams; overload;
    /// <summary>
    /// An upper bound for the number of tokens that can be generated for a completion,
    /// including visible output tokens and reasoning tokens.
    /// </summary>
    function MaxCompletionTokens(const Value: Integer): TChatParams;
    /// <summary>
    /// The maximum number of tokens that can be generated in the chat completion.
    /// The total length of input tokens and generated tokens is limited by the model's context length.
    /// </summary>
    function MaxTokens(const Value: Integer): TChatParams;
    /// <summary>
    /// The maximum number of tokens that can be generated in the chat completion.
    /// The total length of input tokens and generated tokens is limited by the model's context length.
    /// </summary>
    function MaxTokensOld(const Value: Integer): TChatParams; deprecated;
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object.
    /// This can be useful for storing additional information about the object in a structured format,
    /// and querying for objects via API or the dashboard.
    /// Keys are strings with a maximum length of 64 characters.
    /// Values are strings with a maximum length of 512 characters.
    /// </summary>
    function Metadata(const Value: TJSONParam): TChatParams;
    /// <summary>
    /// Output types that you would like the model to generate. Most models are capable of generating text,
    /// which is the default:
    /// ["text"]
    /// The gpt-4o-audio-preview model can also be used to generate audio. To request that this model
    /// generate both text and audio responses, you can use:
    /// ["text", "audio"]
    /// </summary>
    function Modalities(const Value: TArray<string>): TChatParams; overload;
    /// <summary>
    /// Output types that you would like the model to generate. Most models are capable of generating text,
    /// which is the default:
    /// ["text"]
    /// The gpt-4o-audio-preview model can also be used to generate audio. To request that this model
    /// generate both text and audio responses, you can use:
    /// ["text", "audio"]
    /// </summary>
    function Modalities(const Value: TModalities): TChatParams; overload;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear
    /// in the text so far, increasing the model's likelihood to talk about new topics.
    /// </summary>
    function PresencePenalty(const Value: Single = 0): TChatParams;
    /// <summary>
    /// o-series models only
    /// Constrains effort on reasoning for reasoning models. Currently supported values are
    /// low, medium, and high. Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </summary>
    function ReasoningEffort(const Value: TReasoningEffort): TChatParams;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency
    /// in the text so far,
    /// decreasing the model's likelihood to repeat the same line verbatim.
    /// </summary>
    function FrequencyPenalty(const Value: Single = 0): TChatParams;
    /// <summary>
    /// Modify the likelihood of specified tokens appearing in the completion.
    ///
    /// Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias
    /// value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior
    /// to sampling.
    /// The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood
    /// of selection;
    /// values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    /// </summary>
    function LogitBias(const Value: TJSONObject): TChatParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TChatParams;
    /// <summary>
    /// Whether to return log probabilities of the output tokens or not.
    /// If true, returns the log probabilities of each output token returned in the content of message.
    /// This option is currently not available on the gpt-4-vision-preview model.
    /// </summary>
    function Logprobs(const Value: Boolean = True): TChatParams;
    /// <summary>
    /// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position,
    /// each with an associated log probability. logprobs must be set to true if this parameter is used.
    /// </summary>
    function TopLogprobs(const Value: Integer): TChatParams;
    constructor Create; override;
  end;

  TCompletionTokensDetails = class
  private
    FAccepted_prediction_tokens: Int64;
    FAudio_tokens: Int64;
    FReasoning_tokens: Int64;
    FRejected_prediction_tokens: Int64;
  public
    /// <summary>
    /// When using Predicted Outputs, the number of tokens in the prediction that appeared in the completion.
    /// </summary>
    property AcceptedPredictionTokens: Int64 read FAccepted_prediction_tokens write FAccepted_prediction_tokens;
    /// <summary>
    /// Audio input tokens generated by the model.
    /// </summary>
    property AudioTokens: Int64 read FAudio_tokens write FAudio_tokens;
    /// <summary>
    /// Tokens generated by the model for reasoning.
    /// </summary>
    property ReasoningTokens: Int64 read FReasoning_tokens write FReasoning_tokens;
    /// <summary>
    /// When using Predicted Outputs, the number of tokens in the prediction that did not appear in the completion.
    /// However, like reasoning tokens, these tokens are still counted in the total completion tokens for
    /// purposes of billing, output, and context window limits.
    /// </summary>
    property RejectedPredictionTokens: Int64 read FRejected_prediction_tokens write FRejected_prediction_tokens;
  end;

  TPromptTokensDetails = class
  private
    FCached_tokens: Int64;
    FAudio_tokens: Int64;
  public
    /// <summary>
    /// Audio input tokens generated by the model.
    /// </summary>
    property AudioTokens: Int64 read FAudio_tokens write FAudio_tokens;
    /// <summary>
    /// Cached tokens present in the prompt.
    /// </summary>
    property CachedTokens: Int64 read FCached_tokens write FCached_tokens;
  end;

  TChatUsage = class
  private
    FCompletion_tokens: Int64;
    FPrompt_tokens: Int64;
    FTotal_tokens: Int64;
    FCompletion_tokens_details: TCompletionTokensDetails;
    FPrompt_tokens_details: TPromptTokensDetails;
  public
    /// <summary>
    /// Number of tokens in the generated completion.
    /// </summary>
    property CompletionTokens: Int64 read FCompletion_tokens write FCompletion_tokens;
    /// <summary>
    /// Number of tokens in the prompt.
    /// </summary>
    property PromptTokens: Int64 read FPrompt_tokens write FPrompt_tokens;
    /// <summary>
    /// Total number of tokens used in the request (prompt + completion).
    /// </summary>
    property TotalTokens: Int64 read FTotal_tokens write FTotal_tokens;
    /// <summary>
    /// Breakdown of tokens used in a completion.
    /// </summary>
    property CompletionTokensDetails: TCompletionTokensDetails read FCompletion_tokens_details write FCompletion_tokens_details;
    /// <summary>
    /// Breakdown of tokens used in the prompt.
    /// </summary>
    property PromptTokensDetails: TPromptTokensDetails read FPrompt_tokens_details write FPrompt_tokens_details;
    destructor Destroy; override;
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

  TUrlCitation = class
  private
    FEnd_index: Int64;
    FStart_index: Int64;
    FTitle: string;
    FUrl: string;
  public
    /// <summary>
    /// The index of the last character of the URL citation in the message.
    /// </summary>
    property EndIndex: Int64 read FEnd_index write FEnd_index;
    /// <summary>
    /// The index of the first character of the URL citation in the message.
    /// </summary>
    property StartIndex: Int64 read FStart_index write FStart_index;
    /// <summary>
    /// The title of the web resource.
    /// </summary>
    property Title: string read FTitle write FTitle;
    /// <summary>
    /// The URL of the web resource.
    /// </summary>
    property Url: string read FUrl write FUrl;
  end;

  TMessageAnnotation = class
  private
    FType: string;
    FUrl_citation: TUrlCitation;
  public
    /// <summary>
    /// The type of the tool. Currently, only function is supported.
    /// </summary>
    property &Type: string read FType write FType;
    /// <summary>
    /// A URL citation when using web search.
    /// </summary>
    property UrlCitation: TUrlCitation read FUrl_citation write FUrl_citation;
    destructor Destroy; override;
  end;

  TMessageAudio = class
  private
    FData: string;
    FExpires_at: Int64;
    FId: string;
    FTranscript: string;
  public
    /// <summary>
    /// Base64 encoded audio bytes generated by the model,
    /// in the format specified in the request.
    /// </summary>
    property Data: string read FData write FData;
    /// <summary>
    /// The Unix timestamp (in seconds) for when this audio response will no longer
    /// be accessible on the server for use in multi-turn conversations.
    /// </summary>
    property ExpiresAt: Int64 read FExpires_at write FExpires_at;
    /// <summary>
    /// Unique identifier for this audio response.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Transcript of the audio generated by the model.
    /// </summary>
    property Transcript: string read FTranscript write FTranscript;
  end;

  TChatMessage = class
  private
    FRole: string;
    FContent: string;
    FFunction_call: TChatFunctionCall;
    FTool_calls: TArray<TChatToolCall>;
    FRefusal: string;
    FAnnotations: TArray<TMessageAnnotation>;
    FAudio: TMessageAudio;
  public
    /// <summary>
    /// The refusal message generated by the model.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
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
    /// <summary>
    /// Annotations for the message, when applicable, as when using the web search tool.
    /// </summary>
    property Annotations: TArray<TMessageAnnotation> read FAnnotations write FAnnotations;
    /// <summary>
    /// If the audio output modality is requested, this object contains data about the audio response from the model. Learn more.
    /// </summary>
    property Audio: TMessageAudio read FAudio write FAudio;
    destructor Destroy; override;
  end;

  TLogprobContent = class
  private
    FToken: string;
    FLogprob: Extended;
    FBytes: TArray<Integer>;
    FTop_logprobs: TArray<TLogprobContent>;
  public
    /// <summary>
    /// The token.
    /// </summary>
    property Token: string read FToken write FToken;
    /// <summary>
    /// The log probability of this token, if it is within the top 20 most likely tokens.
    /// Otherwise, the value -9999.0 is used to signify that the token is very unlikely.
    /// </summary>
    property Logprob: Extended read FLogprob write FLogprob;
    /// <summary>
    /// A list of integers representing the UTF-8 bytes representation of the token.
    /// Useful in instances where characters are represented by multiple tokens and their byte
    /// representations must be combined to generate the correct text representation.
    /// Can be null if there is no bytes representation for the token.
    /// </summary>
    property Bytes: TArray<Integer> read FBytes write FBytes;
    /// <summary>
    /// List of the most likely tokens and their log probability, at this token position.
    /// In rare cases, there may be fewer than the number of requested top_logprobs returned.
    /// </summary>
    property TopLogprobs: TArray<TLogprobContent> read FTop_logprobs write FTop_logprobs;
    destructor Destroy; override;
  end;

  TLogprobs = class
  private
    FContent: TArray<TLogprobContent>;
    FRefusal: TArray<TLogprobContent>;
  public
    /// <summary>
    /// A list of message content tokens with log probability information.
    /// </summary>
    property Content: TArray<TLogprobContent> read FContent write FContent;
    /// <summary>
    /// A list of message refusal tokens with log probability information.
    /// </summary>
    property Refusal: TArray<TLogprobContent> read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

  TChatChoice = class
  private
    FIndex: Int64;
    FMessage: TChatMessage;
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinish_reason: TFinishReason;
    FDelta: TChatMessage;
    FLogprobs: TLogprobs;
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
    /// <summary>
    /// Log probability information for the choice.
    /// </summary>
    property Logprobs: TLogprobs read FLogprobs write FLogprobs;
    destructor Destroy; override;
  end;

  TChat = class
  private
    FChoices: TArray<TChatChoice>;
    FCreated: Int64;
    FId: string;
    FObject: string;
    FUsage: TChatUsage;
    FModel: string;
    FSystem_fingerprint: string;
    FService_tier: string;
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
    /// The service tier used for processing the request.
    /// This field is only included if the service_tier parameter is specified in the request.
    /// </summary>
    property ServiceTier: string read FService_tier write FService_tier;
    /// <summary>
    /// A list of chat completion choices. Can be more than one if N is greater than 1.
    /// </summary>
    property Choices: TArray<TChatChoice> read FChoices write FChoices;
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
  Rest.Json, System.Rtti, System.Net.HttpClient, OpenAI.Utils.Base64;

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
        TReceiveDataCallback(
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
            if AAbort then
              Exit;
          finally
            Chat.Free;
          end;
        until Ret < 0;
      end));
  finally
    Response.Free;
  end;
end;

{ TChat }

destructor TChat.Destroy;
var
  Item: TChatChoice;
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

function TChatParams.Logprobs(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('logprobs', Value));
end;

function TChatParams.FunctionCall(const Value: TFunctionCall): TChatParams;
begin
  Result := TChatParams(Add('function_call', Value.ToString));
end;

function TChatParams.FrequencyPenalty(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('frequency_penalty', Value));
end;

function TChatParams.MaxCompletionTokens(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_completion_tokens', Value));
end;

function TChatParams.MaxTokens(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_completion_tokens', Value));
end;

function TChatParams.MaxTokensOld(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_tokens', Value));
end;

function TChatParams.Messages(const Value: TArray<TChatMessageBase>): TChatParams;
begin
  Result := TChatParams(Add('messages', TArray<TJSONParam>(Value)));
end;

function TChatParams.Metadata(const Value: TJSONParam): TChatParams;
begin
  Result := TChatParams(Add('metadata', Value));
end;

function TChatParams.Modalities(const Value: TArray<string>): TChatParams;
begin
  Result := TChatParams(Add('modalities', Value));
end;

function TChatParams.Modalities(const Value: TModalities): TChatParams;
begin
  Result := TChatParams(Add('modalities', Value.ToStringArray));
end;

function TChatParams.Model(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('model', Value));
end;

function TChatParams.N(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('n', Value));
end;

function TChatParams.ParallelToolCalls(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('parallel_tool_calls', Value));
end;

function TChatParams.Prediction(const Value: TArray<TMessageContentBase>): TChatParams;
var
  VJO: TJSONParam;
begin
  VJO := TJSONParam.Create;
  VJO.Add('type', 'content');
  VJO.Add('content', TArray<TJSONParam>(Value));
  Result := TChatParams(Add('prediction', VJO));
end;

function TChatParams.PresencePenalty(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('presence_penalty', Value));
end;

function TChatParams.ReasoningEffort(const Value: TReasoningEffort): TChatParams;
begin
  Result := TChatParams(Add('reasoning_effort', Value.ToString));
end;

function TChatParams.ResponseFormat(const Value: TChatResponseFormat; SchemaFormat: TJSONSchemaFormat): TChatParams;
var
  VJO: TJSONParam;
begin
  VJO := TJSONParam.Create;
  try
    VJO.Add('type', Value.ToString);
    if Value = TChatResponseFormat.JSONSchema then
    begin
      VJO.Add('json_schema', SchemaFormat);
      SchemaFormat := nil;
    end;
    Result := TChatParams(Add('response_format', VJO));
  finally
    SchemaFormat.Free;
  end;
end;

function TChatParams.Messages(const Value: TArray<TChatMessageBuild>): TChatParams;
var
  Item: TChatMessageBuild;
  ToolItem: TChatToolCallBuild;
  JSON, ContentItem, ImageUrl: TJSONObject;
  Content: TMessageContent;
  Items, Tools, Contents: TJSONArray;
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
        Contents := TJSONArray.Create;
        JSON.AddPair('content', Contents);
        for Content in Item.Contents do
        begin
          ContentItem := TJSONObject.Create;
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
                ImageUrl := TJSONObject.Create;
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

      //name
      if not Item.AudioId.IsEmpty then
        JSON.AddPair('audio', TJSONObject.Create(TJSONPair.Create('id', Item.AudioId)));

      //function call
      if not Item.FunctionCall.Name.IsEmpty then
      begin
        FuncData := TJSONObject.Create;
        JSON.AddPair('function_call', FuncData);
        FuncData.AddPair('name', Item.FunctionCall.Name);
        FuncData.AddPair('arguments', Item.FunctionCall.Arguments);
      end;

      //Refusal
      if not Item.Refusal.IsEmpty then
        JSON.AddPair('refusal', Item.Refusal);

      //tool calls
      if not Item.ToolCallId.IsEmpty then
        JSON.AddPair('tool_call_id', Item.ToolCallId);

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

function TChatParams.ServiceTier(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('service_tier', Value));
end;

function TChatParams.Stop(const Value: TArray<string>): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Store(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('store', Value));
end;

function TChatParams.Stop(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stream(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('stream', Value));
end;

function TChatParams.StreamOptions(const IncludeUsage: Boolean): TChatParams;
var
  Value: TJSONParam;
begin
  Value := TJSONParam.Create;
  Value.Add('include_usage', IncludeUsage);
  Result := TChatParams(Add('stream_options', Value));
end;

function TChatParams.Temperature(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('temperature', Value));
end;

function TChatParams.ToolChoice(const Value: TChatToolChoiceParam): TChatParams;
var
  VJO, VJF: TJSONParam;
begin
  case Value.FType of
    TFunctionCallType.None:
      Result := TChatParams(Add('tool_choice', 'none'));
    TFunctionCallType.Auto:
      Result := TChatParams(Add('tool_choice', 'auto'));
    TFunctionCallType.Func:
      begin
        VJO := TJSONParam.Create;
        VJO.Add('type', 'function');
        VJF := TJSONParam.Create;
        VJO.Add('function', VJF);
        VJF.Add('name', Value.FFuncName);
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

function TChatParams.TopLogprobs(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('top_logprobs', Value));
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

class function TChatMessageBuild.Assistant(const Content: TArray<TMessageContent>; const Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Assistant;
  Result.FContents := Content;
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

class function TChatMessageBuild.Developer(const Content: TArray<TMessageContent>; const Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Developer;
  Result.FContents := Content;
  Result.FName := Name;
end;

class function TChatMessageBuild.Developer(const Content, Name: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Developer;
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
  else if Value = 'developer' then
    Exit(TMessageRole.Developer)
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
    TMessageRole.Developer:
      Result := 'developer';
  end;
end;

{ TChatChoices }

destructor TChatChoice.Destroy;
begin
  FMessage.Free;
  FDelta.Free;
  FLogprobs.Free;
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
  Annotation: TMessageAnnotation;
begin
  FFunction_call.Free;
  FAudio.Free;
  for Item in FTool_calls do
    Item.Free;
  for Annotation in FAnnotations do
    Annotation.Free;
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
  else if Value = 'tool_calls' then
    Exit(TFinishReason.ToolCalls)
  else if Value = 'null' then
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
    TFinishReason.ToolCalls:
      Exit('tool_calls');
    TFinishReason.Null:
      Exit('null');
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

class function TMessageContent.CreateImage(const Data: TStream; const FileContentType: string; const Detail: TImageDetail): TMessageContent;
begin
  Result := CreateImage(StreamToBase64(Data, FileContentType), Detail);
end;

class function TMessageContent.CreateImage(const Data: TBase64Data; const Detail: TImageDetail): TMessageContent;
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

{ TLogprobs }

destructor TLogprobs.Destroy;
var
  Item: TLogprobContent;
begin
  for Item in FContent do
    Item.Free;
  for Item in FRefusal do
    Item.Free;
  inherited;
end;

{ TLogprobContent }

destructor TLogprobContent.Destroy;
var
  Item: TLogprobContent;
begin
  for Item in FTop_logprobs do
    Item.Free;
  inherited;
end;

{ TJSONSchemaFormat }

function TJSONSchemaFormat.Description(const Value: string): TJSONSchemaFormat;
begin
  Result := TJSONSchemaFormat(Add('description', Value));
end;

function TJSONSchemaFormat.Name(const Value: string): TJSONSchemaFormat;
begin
  Result := TJSONSchemaFormat(Add('name', Value));
end;

function TJSONSchemaFormat.Schema(const Value: TJSONValue): TJSONSchemaFormat;
begin
  Result := TJSONSchemaFormat(Add('schema', Value));
end;

function TJSONSchemaFormat.strict(const Value: Boolean): TJSONSchemaFormat;
begin
  Result := TJSONSchemaFormat(Add('strict', Value));
end;

{ TMessageAnnotation }

destructor TMessageAnnotation.Destroy;
begin
  FUrl_citation.Free;
  inherited;
end;

{ TChatUsage }

destructor TChatUsage.Destroy;
begin
  FCompletion_tokens_details.Free;
  FPrompt_tokens_details.Free;
  inherited;
end;

{ TChatMessageBase }

function TChatMessageBase.Role(const Value: string): TChatMessageBase;
begin
  Result := TChatMessageBase(Add('role', Value));
end;

function TChatMessageBase.Assistant: TChatMessageAssistant;
begin
  Result := TChatMessageAssistant.Create;
end;

function TChatMessageBase.Developer: TChatMessageDeveloper;
begin
  Result := TChatMessageDeveloper.Create;
end;

function TChatMessageBase.&Function: TChatMessageFunction;
begin
  {$WARNINGS OFF}
  Result := TChatMessageFunction.Create;
  {$WARNINGS ON}
end;

function TChatMessageBase.System: TChatMessageSystem;
begin
  Result := TChatMessageSystem.Create;
end;

function TChatMessageBase.Tool: TChatMessageTool;
begin
  Result := TChatMessageTool.Create;
end;

function TChatMessageBase.User: TChatMessageUser;
begin
  Result := TChatMessageUser.Create;
end;

{ TChatMessageDeveloper }

constructor TChatMessageDeveloper.Create;
begin
  inherited;
  Role('developer');
end;

function TChatMessageDeveloper.Content(const Value: string): TChatMessageDeveloper;
begin
  Result := TChatMessageDeveloper(Add('content', Value));
end;

function TChatMessageDeveloper.Content(const Value: TArray<TMessageContentBase>): TChatMessageDeveloper;
begin
  Result := TChatMessageDeveloper(Add('content', TArray<TJSONParam>(Value)));
end;

function TChatMessageDeveloper.Name(const Value: string): TChatMessageDeveloper;
begin
  Result := TChatMessageDeveloper(Add('name', Value));
end;

{ TChatMessageSystem }

constructor TChatMessageSystem.Create;
begin
  inherited;
  Role('system');
end;

function TChatMessageSystem.Content(const Value: string): TChatMessageSystem;
begin
  Result := TChatMessageSystem(Add('content', Value));
end;

function TChatMessageSystem.Content(const Value: TArray<TMessageContentBase>): TChatMessageSystem;
begin
  Result := TChatMessageSystem(Add('content', TArray<TJSONParam>(Value)));
end;

function TChatMessageSystem.Name(const Value: string): TChatMessageSystem;
begin
  Result := TChatMessageSystem(Add('name', Value));
end;

{ TMessageContentBase }

function TMessageContentBase.ContentType(const Value: string): TMessageContentBase;
begin
  Result := TMessageContentBase(Add('type', Value));
end;

{ TChatMessageUser }

constructor TChatMessageUser.Create;
begin
  inherited;
  Role('user');
end;

function TChatMessageUser.Content(const Value: string): TChatMessageUser;
begin
  Result := TChatMessageUser(Add('content', Value));
end;

function TChatMessageUser.Content(const Value: TArray<TMessageContentBase>): TChatMessageUser;
begin
  Result := TChatMessageUser(Add('content', TArray<TJSONParam>(Value)));
end;

function TChatMessageUser.Name(const Value: string): TChatMessageUser;
begin
  Result := TChatMessageUser(Add('name', Value));
end;

{ TChatMessageAssistant }

constructor TChatMessageAssistant.Create;
begin
  inherited;
  Role('assistant');
end;

function TChatMessageAssistant.Content(const Value: string): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('content', Value));
end;

function TChatMessageAssistant.Audio(const Id: string): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('audio', TJSONParam.Create.Add('id', Id)));
end;

function TChatMessageAssistant.Content(const Value: TArray<TMessageContentBase>): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('content', TArray<TJSONParam>(Value)));
end;

function TChatMessageAssistant.FunctionCall(const Name, Arguments: string): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('function_call', TJSONParam.Create.Add('name', Name).Add('arguments', Arguments)));
end;

function TChatMessageAssistant.Name(const Value: string): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('name', Value));
end;

function TChatMessageAssistant.Refusal(const Value: string): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('refusal', Value));
end;

function TChatMessageAssistant.ToolCalls(const Value: TArray<TToolCall>): TChatMessageAssistant;
begin
  Result := TChatMessageAssistant(Add('tool_calls', TArray<TJSONParam>(Value)));
end;

{ TToolCall }

function TToolCall.&Type(const Value: string): TToolCall;
begin
  Result := TToolCall(Add('type', Value));
end;

{ TToolCallFunction }

constructor TToolCallFunction.Create;
begin
  inherited;
  &Type('function');
end;

function TToolCallFunction.&Function(const Name, Arguments: string): TToolCallFunction;
begin
  Result := TToolCallFunction(Add('function', TJSONParam.Create.Add('name', Name).Add('arguments', Arguments)));
end;

function TToolCallFunction.Id(const Value: string): TToolCallFunction;
begin
  Result := TToolCallFunction(Add('id', Value));
end;

{ TChatMessageTool }

constructor TChatMessageTool.Create;
begin
  inherited;
  Role('tool');
end;

function TChatMessageTool.Content(const Value: string): TChatMessageTool;
begin
  Result := TChatMessageTool(Add('content', Value));
end;

function TChatMessageTool.Content(const Value: TArray<TMessageContentBase>): TChatMessageTool;
begin
  Result := TChatMessageTool(Add('content', TArray<TJSONParam>(Value)));
end;

function TChatMessageTool.ToolCallId(const Value: string): TChatMessageTool;
begin
  Result := TChatMessageTool(Add('tool_call_id', Value));
end;

{ TChatMessageFunction }

constructor TChatMessageFunction.Create;
begin
  inherited;
  Role('function');
end;

function TChatMessageFunction.Content(const Value: string): TChatMessageFunction;
begin
  Result := TChatMessageFunction(Add('content', Value));
end;

function TChatMessageFunction.Name(const Value: string): TChatMessageFunction;
begin
  Result := TChatMessageFunction(Add('name', Value));
end;

{ TMessageContentText }

constructor TMessageContentText.Create;
begin
  inherited;
  ContentType('text');
end;

function TMessageContentText.Text(const Value: string): TMessageContentText;
begin
  Result := TMessageContentText(Add('text', Value));
end;

{ TMessageContentImage }

constructor TMessageContentImage.Create;
begin
  inherited;
  ContentType('image_url');
end;

function TMessageContentImage.ImageUrl(const Url, Detail: string): TMessageContentImage;
var
  Data: TJSONParam;
begin
  Data := TJSONParam.Create.Add('url', Url);
  if not Detail.IsEmpty then
    Data.Add('detail', Detail);
  Result := TMessageContentImage(Add('image_url', Data));
end;

{ TMessageContentAudio }

constructor TMessageContentAudio.Create;
begin
  inherited;
  ContentType('input_audio');
end;

function TMessageContentAudio.InputAudio(const Data, Format: string): TMessageContentAudio;
begin
  Result := TMessageContentAudio(Add('input_audio', TJSONParam.Create.Add('data', Data).Add('format', Format)));
end;

{ TMessageContentFile }

constructor TMessageContentFile.Create;
begin
  inherited;
  ContentType('file');
end;

function TMessageContentFile.FileData(const Value: string): TMessageContentFile;
begin
  Result := TMessageContentFile(Add('file', TJSONParam.Create.Add('file_data', Value)));
end;

function TMessageContentFile.FileId(const Value: string): TMessageContentFile;
begin
  Result := TMessageContentFile(Add('file', TJSONParam.Create.Add('file_id', Value)));
end;

function TMessageContentFile.FileName(const Value: string): TMessageContentFile;
begin
  Result := TMessageContentFile(Add('file', TJSONParam.Create.Add('file_name', Value)));
end;

{ TMessageContentRefusal }

constructor TMessageContentRefusal.Create;
begin
  inherited;
  ContentType('refusal');
end;

function TMessageContentRefusal.Refusal(const Value: string): TMessageContentFile;
begin
  Result := TMessageContentFile(Add('refusal', Value));
end;

{ TModalitiesHelper }

function TModalitiesHelper.ToStringArray: TArray<string>;
var
  Item: TModality;
begin
  for Item in Self do
    Result := Result + [Item.ToString];
end;

{ TModalityHelper }

function TModalityHelper.ToString: string;
begin
  case Self of
    TModality.Text:
      Exit('text');
    TModality.Audio:
      Exit('audio');
  else
    raise Exception.Create('Unknown TModality value');
  end;
end;

{ TReasoningEffortHelper }

function TReasoningEffortHelper.ToString: string;
begin
  case Self of
    TReasoningEffort.Low:
      Exit('low');
    TReasoningEffort.Medium:
      Exit('medium');
    TReasoningEffort.High:
      Exit('high');
  else
    raise Exception.Create('Unknown TReasoningEffort value');
  end;
end;

end.


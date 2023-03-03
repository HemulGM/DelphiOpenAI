unit OpenAI.Chat;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API;

{$SCOPEDENUMS ON}

type
  TMessageRole = (System, User, Assistant);

  TMessageRoleHelper = record helper for TMessageRole
    function ToString: string;
  end;

  TChatMessageBuild = record
  private
    FRole: TMessageRole;
    FContent: string;
  public
    property Role: TMessageRole read FRole write FRole;
    property Content: string read FContent write FContent;
    class function Create(Role: TMessageRole; Content: string): TChatMessageBuild; static;
    class function User(Content: string): TChatMessageBuild; static;
    class function System(Content: string): TChatMessageBuild; static;
    class function Assistant(Content: string): TChatMessageBuild; static;
  end;

  TChatParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
    /// </summary>
    function Model(const Value: string): TChatParams;
    /// <summary>
    /// The messages to generate chat completions for, in the chat format.
    /// </summary>
    function Messages(const Value: TArray<TChatMessageBuild>): TChatParams; overload;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic.
    /// We generally recommend altering this or top_p but not both.
    /// </summary>
    function Temperature(const Value: Single = 1): TChatParams;
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
    property CompletionTokens: Int64 read FCompletion_tokens write FCompletion_tokens;
    property PromptTokens: Int64 read FPrompt_tokens write FPrompt_tokens;
    property TotalTokens: Int64 read FTotal_tokens write FTotal_tokens;
  end;

  TChatMessage = class
  private
    FRole: string;
    FContent: string;
  public
    property Role: string read FRole write FRole;
    property Content: string read FContent write FContent;
  end;

  TChatChoices = class
  private
    FIndex: Int64;
    FMessage: TChatMessage;
    FFinish_reason: string;
  public
    property Index: Int64 read FIndex write FIndex;
    property Message: TChatMessage read FMessage write FMessage;
    property FinishReason: string read FFinish_reason write FFinish_reason;
    destructor Destroy; override;
  end;

  TChat = class
  private
    FChoices: TArray<TChatChoices>;
    FCreated: Int64;
    FId: string;
    FObject: string;
    FUsage: TChatUsage;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property Created: Int64 read FCreated write FCreated;
    property Choices: TArray<TChatChoices> read FChoices write FChoices;
    property Usage: TChatUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Given a chat conversation, the model will return a chat completion response.
  /// </summary>
  TChatRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a completion for the chat message
    /// </summary>
    function Create(ParamProc: TProc<TChatParams>): TChat;
  end;

implementation

uses
  System.JSON;

{ TChatRoute }

function TChatRoute.Create(ParamProc: TProc<TChatParams>): TChat;
begin
  Result := API.Post<TChat, TChatParams>('chat/completions', ParamProc);
end;

{ TChat }

destructor TChat.Destroy;
begin
  if Assigned(FUsage) then
    FUsage.Free;
  for var Item in FChoices do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TChatParams }

constructor TChatParams.Create;
begin
  inherited;
  Model('gpt-3.5-turbo');
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

function TChatParams.Messages(const Value: TArray<TChatMessageBuild>): TChatParams;
var
  Item: TChatMessageBuild;
  JSON: TJSONObject;
  Items: TJSONArray;
begin
  Items := TJSONArray.Create;
  for Item in Value do
  begin
    JSON := TJSONObject.Create;
    JSON.AddPair('role', Item.Role.ToString);
    JSON.AddPair('content', Item.Content);
    Items.Add(JSON);
  end;
  Result := TChatParams(Add('messages', Items));
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

function TChatParams.TopP(const Value: Single): TChatParams;
begin
  Result := TChatParams(Add('top_p', Value));
end;

function TChatParams.User(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('user', Value));
end;

{ TChatMessageBuild }

class function TChatMessageBuild.Assistant(Content: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.Assistant;
  Result.FContent := Content;
end;

class function TChatMessageBuild.Create(Role: TMessageRole; Content: string): TChatMessageBuild;
begin
  Result.FRole := Role;
  Result.FContent := Content;
end;

class function TChatMessageBuild.System(Content: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.System;
  Result.FContent := Content;
end;

class function TChatMessageBuild.User(Content: string): TChatMessageBuild;
begin
  Result.FRole := TMessageRole.User;
  Result.FContent := Content;
end;

{ TMessageRoleHelper }

function TMessageRoleHelper.ToString: string;
begin
  case Self of
    TMessageRole.System:
      Result := 'system';
    TMessageRole.User:
      Result := 'user';
    TMessageRole.Assistant:
      Result := 'assistant';
  end;
end;

{ TChatChoices }

destructor TChatChoices.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;
  inherited;
end;

end.


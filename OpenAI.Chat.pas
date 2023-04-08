unit OpenAI.Chat;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API, System.Classes;

{$SCOPEDENUMS ON}

type
  TMessageRole = (System, User, Assistant);

  TMessageRoleHelper = record helper for TMessageRole
    function ToString: string;
    class function FromString(const Value: string): TMessageRole; static;
  end;

  TChatMessageBuild = record
  private
    FRole: TMessageRole;
    FContent: string;
    FTag: string;
  public
    property Role: TMessageRole read FRole write FRole;
    property Content: string read FContent write FContent;
    /// <summary>
    /// Tag - custom field for convenience. Not used in requests
    /// </summary>
    property Tag: string read FTag write FTag;
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
    FDelta: TChatMessage;
  public
    property Index: Int64 read FIndex write FIndex;
    property Message: TChatMessage read FMessage write FMessage;
    property Delta: TChatMessage read FDelta write FDelta;
    /// <summary>
    /// The possible values for finish_reason are:
    /// stop: API returned complete model output
    /// length: Incomplete model output due to max_tokens parameter or token limit
    /// content_filter: Omitted content due to a flag from our content filters
    /// null: API response still in progress or incomplete
    /// </summary>
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

  TChatEvent = reference to procedure(Chat: TChat; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Given a chat conversation, the model will return a chat completion response.
  /// </summary>
  TChatRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a completion for the chat message
    /// </summary>
    function Create(ParamProc: TProc<TChatParams>): TChat;
    /// <summary>
    /// Creates a completion for the chat message
    /// </summary>
    function CreateStream(ParamProc: TProc<TChatParams>; Event: TChatEvent): Boolean;
  end;

implementation

uses
  System.JSON, Rest.Json;

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
        TextBuffer := Response.DataString;
        repeat
          Ret := TextBuffer.IndexOf(#10, RetPos);
          if Ret >= 0 then
          begin
            Line := TextBuffer.Substring(RetPos, Ret - RetPos);
            RetPos := Ret + 1;
            if Line.IsEmpty or (Line.StartsWith(#10)) then
              Continue;
            Chat := nil;
            Data := Line.Replace('data: ', '').Trim([' ', #13, #10]);
            IsDone := Data = '[DONE]';
            if not IsDone then
            begin
              try
                Chat := TJson.JsonToObject<TChat>(Data);
              except
                Chat := nil;
              end;
            end;
            try
              Event(Chat, IsDone, AAbort);
            finally
              if Assigned(Chat) then
                Chat.Free;
            end;
          end;
        until Ret < 0;
      end);
  finally
    Response.Free;
  end;
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

class function TMessageRoleHelper.FromString(const Value: string): TMessageRole;
begin
  if Value = 'system' then
    Exit(TMessageRole.System)
  else if Value = 'user' then
    Exit(TMessageRole.User)
  else if Value = 'assistant' then
    Exit(TMessageRole.Assistant)
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

end.


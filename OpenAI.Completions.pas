unit OpenAI.Completions;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API;

type
  TCompletionParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. You can use the List models API to see all of your available models,
    /// or see our Model overview for descriptions of them.
    /// </summary>
    function Model(const Value: string): TCompletionParams;
    /// <summary>
    /// The prompt(s) to generate completions for, encoded as a string, array of strings, array of tokens, or array of token arrays.
    /// Note that <|endoftext|> is the document separator that the model sees during training, so if a prompt is not specified the model will generate as if from the beginning of a new document.
    /// </summary>
    function Prompt(const Value: string): TCompletionParams; overload;
    /// <summary>
    /// The prompt(s) to generate completions for, encoded as a string, array of strings, array of tokens, or array of token arrays.
    /// Note that <|endoftext|> is the document separator that the model sees during training, so if a prompt is not specified the model will generate as if from the beginning of a new document.
    /// </summary>
    function Prompt(const Value: TArray<string>): TCompletionParams; overload;
    /// <summary>
    /// The suffix that comes after a completion of inserted text.
    /// </summary>
    function Suffix(const Value: string = ''): TCompletionParams; overload;
    /// <summary>
    /// The maximum number of tokens to generate in the completion.
    /// The token count of your prompt plus max_tokens cannot exceed the model's context length.
    /// Most models have a context length of 2048 tokens (except for the newest models, which support 4096).
    /// </summary>
    function MaxTokens(const Value: Integer = 16): TCompletionParams;
    /// <summary>
    /// What sampling temperature to use. Higher values means the model will take more risks.
    /// Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer.
    /// We generally recommend altering this or top_p but not both.
    /// </summary>
    function Temperature(const Value: Single = 1): TCompletionParams;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling,
    /// where the model considers the results of the tokens with top_p probability mass.
    /// So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    /// We generally recommend altering this or temperature but not both.
    /// </summary>
    function TopP(const Value: Single = 1): TCompletionParams;
    /// <summary>
    /// How many completions to generate for each prompt.
    /// Note: Because this parameter generates many completions, it can quickly consume your token quota.
    /// Use carefully and ensure that you have reasonable settings for max_tokens and stop.
    /// </summary>
    function N(const Value: Integer = 1): TCompletionParams;
    /// <summary>
    /// Whether to stream back partial progress.
    /// If set, tokens will be sent as data-only server-sent events as they become available,
    /// with the stream terminated by a data: [DONE] message.
    /// </summary>
    function Stream(const Value: Boolean = True): TCompletionParams;
    /// <summary>
    /// Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens.
    /// For example, if logprobs is 5, the API will return a list of the 5 most likely tokens.
    /// The API will always return the logprob of the sampled token, so there may be up to logprobs+1 elements in the response.
    /// The maximum value for logprobs is 5. If you need more than this, please contact us through our Help center and
    /// describe your use case.
    /// </summary>
    function LogProbs(const Value: Integer): TCompletionParams;
    /// <summary>
    /// Echo back the prompt in addition to the completion
    /// </summary>
    function Echo(const Value: Boolean = True): TCompletionParams;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    /// </summary>
    function Stop(const Value: string): TCompletionParams; overload;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    /// </summary>
    function Stop(const Value: TArray<string>): TCompletionParams; overload;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far,
    /// increasing the model's likelihood to talk about new topics.
    /// </summary>
    function PresencePenalty(const Value: Single = 0): TCompletionParams;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far,
    /// decreasing the model's likelihood to repeat the same line verbatim.
    /// </summary>
    function FrequencyPenalty(const Value: Single = 0): TCompletionParams;
    /// <summary>
    ///  Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token).
    /// Results cannot be streamed.
    ///  When used with n, best_of controls the number of candidate completions and n specifies how many to return – best_of must be greater than n.
    ///  Note: Because this parameter generates many completions, it can quickly consume your token quota.
    /// Use carefully and ensure that you have reasonable settings for max_tokens and stop
    /// </summary>
    function BestOf(const Value: Integer = 1): TCompletionParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse
    /// </summary>
    function User(const Value: string): TCompletionParams;
    constructor Create; override;
  end;

  TCompletionUsage = class
  private
    FCompletion_tokens: Int64;
    FPrompt_tokens: Int64;
    FTotal_tokens: Int64;
  public
    property CompletionTokens: Int64 read FCompletion_tokens write FCompletion_tokens;
    property PromptTokens: Int64 read FPrompt_tokens write FPrompt_tokens;
    property TotalTokens: Int64 read FTotal_tokens write FTotal_tokens;
  end;

  TCompletionChoices = class
  private
    FFinish_reason: string;
    FIndex: Int64;
    FText: string;
  public
    property FinishReason: string read FFinish_reason write FFinish_reason;
    property Index: Int64 read FIndex write FIndex;
    property Text: string read FText write FText;
  end;

  TCompletions = class
  private
    FChoices: TArray<TCompletionChoices>;
    FCreated: Int64;
    FId: string;
    FModel: string;
    FObject: string;
    FUsage: TCompletionUsage;
  public
    property Choices: TArray<TCompletionChoices> read FChoices write FChoices;
    property Created: Int64 read FCreated write FCreated;
    property Id: string read FId write FId;
    property Model: string read FModel write FModel;
    property &Object: string read FObject write FObject;
    property Usage: TCompletionUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  TCompletionsRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a completion for the provided prompt and parameters
    /// </summary>
    function Create(ParamProc: TProc<TCompletionParams>): TCompletions;
  end;

implementation

{ TCompletionsRoute }

function TCompletionsRoute.Create(ParamProc: TProc<TCompletionParams>): TCompletions;
begin
  Result := API.Post<TCompletions, TCompletionParams>('completions', ParamProc);
end;

{ TCompletions }

destructor TCompletions.Destroy;
var
  Item: TCompletionChoices;
begin
  if Assigned(FUsage) then
    FUsage.Free;
  for Item in FChoices do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TCompletionParams }

function TCompletionParams.BestOf(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('best_of', Value));
end;

constructor TCompletionParams.Create;
begin
  inherited;
  Model('text-davinci-003');
  Temperature(0);
end;

function TCompletionParams.Echo(const Value: Boolean): TCompletionParams;
begin
  Result := TCompletionParams(Add('echo', Value));
end;

function TCompletionParams.FrequencyPenalty(const Value: Single): TCompletionParams;
begin
  Result := TCompletionParams(Add('frequency_penalty', Value));
end;

function TCompletionParams.LogProbs(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('logprobs', Value));
end;

function TCompletionParams.MaxTokens(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('max_tokens', Value));
end;

function TCompletionParams.Model(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('model', Value));
end;

function TCompletionParams.N(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('n', Value));
end;

function TCompletionParams.PresencePenalty(const Value: Single): TCompletionParams;
begin
  Result := TCompletionParams(Add('presence_penalty', Value));
end;

function TCompletionParams.Prompt(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('prompt', Value));
end;

function TCompletionParams.Prompt(const Value: TArray<string>): TCompletionParams;
begin
  Result := TCompletionParams(Add('prompt', Value));
end;

function TCompletionParams.Stop(const Value: TArray<string>): TCompletionParams;
begin
  Result := TCompletionParams(Add('stop', Value));
end;

function TCompletionParams.Stop(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('stop', Value));
end;

function TCompletionParams.Stream(const Value: Boolean): TCompletionParams;
begin
  Result := TCompletionParams(Add('stream', Value));
end;

function TCompletionParams.Suffix(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('suffix', Value));
end;

function TCompletionParams.Temperature(const Value: Single): TCompletionParams;
begin
  Result := TCompletionParams(Add('temperature', Value));
end;

function TCompletionParams.TopP(const Value: Single): TCompletionParams;
begin
  Result := TCompletionParams(Add('top_p', Value));
end;

function TCompletionParams.User(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('user', Value));
end;

end.


unit OpenAI.Edits;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API;

type
  TEditParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. You can use the "text-davinci-edit-001" or
    /// "code-davinci-edit-001" model with this endpoint.
    /// </summary>
    function Model(const Value: string): TEditParams;
    /// <summary>
    /// The input text to use as a starting point for the edit.
    /// </summary>
    function Input(const Value: string): TEditParams; overload;
    /// <summary>
    /// The instruction that tells the model how to edit the prompt.
    /// </summary>
    function Instruction(const Value: string): TEditParams; overload;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2.
    /// Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic.
    /// We generally recommend altering this or top_p but not both.
    /// </summary>
    function Temperature(const Value: Single = 1): TEditParams;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling,
    /// where the model considers the results of the tokens with top_p probability mass.
    /// So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    /// We generally recommend altering this or temperature but not both.
    /// </summary>
    function TopP(const Value: Single = 1): TEditParams;
    /// <summary>
    /// How many edits to generate for the input and instruction.
    /// </summary>
    function N(const Value: Integer = 1): TEditParams;
    constructor Create; override;
  end;

  TEditUsage = class
  private
    FCompletion_tokens: Int64;
    FPrompt_tokens: Int64;
    FTotal_tokens: Int64;
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
  end;

  TEditChoices = class
  private
    FIndex: Int64;
    FText: string;
    FFinish_reason: string;
  public
    /// <summary>
    /// The index of the choice in the list of choices.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;
    /// <summary>
    /// The edited result.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// The reason the model stopped generating tokens.
    /// This will be "stop" if the model hit a natural stop point or a provided stop sequence,
    /// "length" if the maximum number of tokens specified in the request was reached,
    /// or "content_filter" if content was omitted due to a flag from our content filters.
    /// </summary>
    property FinishReason: string read FFinish_reason write FFinish_reason;
  end;

  TEdits = class
  private
    FChoices: TArray<TEditChoices>;
    FCreated: Int64;
    FObject: string;
    FUsage: TEditUsage;
  public
    /// <summary>
    /// The object type, which is always "edit".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// A list of edit choices. Can be more than one if n is greater than 1.
    /// </summary>
    property Choices: TArray<TEditChoices> read FChoices write FChoices;
    /// <summary>
    /// The Unix timestamp (in seconds) of when the edit was created.
    /// </summary>
    property Created: Int64 read FCreated write FCreated;
    /// <summary>
    /// Usage statistics for the completion request.
    /// </summary>
    property Usage: TEditUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  TEditsRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a new edit for the provided input, instruction, and parameters
    /// </summary>
    function Create(ParamProc: TProc<TEditParams>): TEdits; deprecated;
  end;

implementation

{ TEditsRoute }

function TEditsRoute.Create(ParamProc: TProc<TEditParams>): TEdits;
begin
  Result := API.Post<TEdits, TEditParams>('edits', ParamProc);
end;

{ TEdits }

destructor TEdits.Destroy;
var
  Item: TEditChoices;
begin
  if Assigned(FUsage) then
    FUsage.Free;
  for Item in FChoices do
    Item.Free;
  inherited;
end;

{ TEditParams }

constructor TEditParams.Create;
begin
  inherited;
  Model('text-davinci-edit-001');
end;

function TEditParams.Model(const Value: string): TEditParams;
begin
  Result := TEditParams(Add('model', Value));
end;

function TEditParams.N(const Value: Integer): TEditParams;
begin
  Result := TEditParams(Add('n', Value));
end;

function TEditParams.Input(const Value: string): TEditParams;
begin
  Result := TEditParams(Add('input', Value));
end;

function TEditParams.Instruction(const Value: string): TEditParams;
begin
  Result := TEditParams(Add('instruction', Value));
end;

function TEditParams.Temperature(const Value: Single): TEditParams;
begin
  Result := TEditParams(Add('temperature', Value));
end;

function TEditParams.TopP(const Value: Single): TEditParams;
begin
  Result := TEditParams(Add('top_p', Value));
end;

end.


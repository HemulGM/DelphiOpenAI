unit ChatGPT.API.Embeddings;

interface

uses
  ChatGPT.API.Params;

type
  TEmbeddingParams = class(TJSONParam)
    /// <summary>
    /// ID of the model to use. You can use the List models API to see all of your available models,
    /// or see our Model overview for descriptions of them.
    /// </summary>
    function Model(const Value: string): TEmbeddingParams;
    /// <summary>
    /// Input text to get embeddings for, encoded as a string or array of tokens.
    /// To get embeddings for multiple inputs in a single request, pass an array of strings or array of token arrays.
    /// Each input must not exceed 8192 tokens in length.
    /// </summary>
    function Input(const Value: string): TEmbeddingParams; overload;
    /// <summary>
    /// Input text to get embeddings for, encoded as a string or array of tokens.
    /// To get embeddings for multiple inputs in a single request, pass an array of strings or array of token arrays.
    /// Each input must not exceed 8192 tokens in length.
    /// </summary>
    function Input(const Value: TArray<string>): TEmbeddingParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TEmbeddingParams; overload;
  end;

  TGPTEmbeddingUsage = class
  private
    FPrompt_tokens: Int64;
    FTotal_tokens: Int64;
  public
    property PromptTokens: Int64 read FPrompt_tokens write FPrompt_tokens;
    property TotalTokens: Int64 read FTotal_tokens write FTotal_tokens;
  end;

  TGPTEmbeddingData = class
  private
    FIndex: Int64;
    FObject: string;
    FEmbedding: TArray<Extended>;
  public
    property &Object: string read FObject write FObject;
    property Index: Int64 read FIndex write FIndex;
    property Embedding: TArray<Extended> read FEmbedding write FEmbedding;
  end;

  TGPTEmbeddings = class
  private
    FData: TArray<TGPTEmbeddingData>;
    FObject: string;
    FUsage: TGPTEmbeddingUsage;
    FModel: string;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TGPTEmbeddingData> read FData write FData;
    property Usage: TGPTEmbeddingUsage read FUsage write FUsage;
    property Model: string read FModel write FModel;
    destructor Destroy; override;
  end;

implementation

{ TGPTEmbeddings }

destructor TGPTEmbeddings.Destroy;
begin
  if Assigned(FUsage) then
    FUsage.Free;
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TEmbeddingParams }

function TEmbeddingParams.Input(const Value: TArray<string>): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('input', Value));
end;

function TEmbeddingParams.Model(const Value: string): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('model', Value));
end;

function TEmbeddingParams.Input(const Value: string): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('input', Value));
end;

function TEmbeddingParams.User(const Value: string): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('user', Value));
end;

end.


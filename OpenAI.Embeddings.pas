unit OpenAI.Embeddings;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API;

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

  TEmbeddingUsage = class
  private
    FPrompt_tokens: Int64;
    FTotal_tokens: Int64;
  public
    property PromptTokens: Int64 read FPrompt_tokens write FPrompt_tokens;
    property TotalTokens: Int64 read FTotal_tokens write FTotal_tokens;
  end;

  TEmbeddingData = class
  private
    FIndex: Int64;
    FObject: string;
    FEmbedding: TArray<Extended>;
  public
    /// <summary>
    /// The index of the embedding in the list of embeddings.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;
    /// <summary>
    /// The object type, which is always "embedding".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The embedding vector, which is a list of floats. The length of vector depends on the model as listed in the embedding guide.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/embeddings</seealso>
    property Embedding: TArray<Extended> read FEmbedding write FEmbedding;
  end;

  TEmbeddings = class
  private
    FData: TArray<TEmbeddingData>;
    FObject: string;
    FUsage: TEmbeddingUsage;
    FModel: string;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TEmbeddingData> read FData write FData;
    property Usage: TEmbeddingUsage read FUsage write FUsage;
    property Model: string read FModel write FModel;
    destructor Destroy; override;
  end;

  TEmbeddingsRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates an embedding vector representing the input text.
    /// </summary>
    function Create(ParamProc: TProc<TEmbeddingParams>): TEmbeddings;
  end;

implementation

{ TEmbeddingsRoute }

function TEmbeddingsRoute.Create(ParamProc: TProc<TEmbeddingParams>): TEmbeddings;
begin
  Result := API.Post<TEmbeddings, TEmbeddingParams>('embeddings', ParamProc);
end;

{ TEmbeddings }

destructor TEmbeddings.Destroy;
var
  Item: TEmbeddingData;
begin
  FUsage.Free;
  for Item in FData do
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


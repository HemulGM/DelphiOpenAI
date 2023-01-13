unit OpenAI;

interface

uses
  System.SysUtils, System.Classes, OpenAI.Completions, OpenAI.Edits,
  OpenAI.Errors, OpenAI.Params, OpenAI.Images, OpenAI.Models, OpenAI.Embeddings,
  OpenAI.API, OpenAI.Moderations, OpenAI.Engines, OpenAI.Files;

type
  {$WARNINGS OFF}
  TOpenAI = class(TComponent)
  private
    FCompletionsRoute: TCompletionsRoute;
    FAPI: TOpenAIAPI;
    FEditsRoute: TEditsRoute;
    FImagesRoute: TImagesRoute;
    FModelsRoute: TModelsRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FModerationsRoute: TModerationsRoute;
    FEnginesRoute: TEnginesRoute;
    FFilesRoute: TFilesRoute;
    procedure SetToken(const Value: string);
    function GetToken: string;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read GetToken write SetToken;
    property API: TOpenAIAPI read FAPI;
  public
    /// <summary>
    /// Given a prompt, the model will return one or more predicted completions,
    /// and can also return the probabilities of alternative tokens at each position.
    /// </summary>
    property Completion: TCompletionsRoute read FCompletionsRoute;
    /// <summary>
    /// Given a prompt and an instruction, the model will return an edited version of the prompt.
    /// </summary>
    property Edit: TEditsRoute read FEditsRoute;
    /// <summary>
    /// Given a prompt and/or an input image, the model will generate a new image.
    /// </summary>
    property Image: TImagesRoute read FImagesRoute;
    /// <summary>
    /// List and describe the various models available in the API.
    /// You can refer to the Models documentation to understand what models are available and the differences between them.
    /// </summary>
    property Model: TModelsRoute read FModelsRoute;
    /// <summary>
    /// Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.
    /// </summary>
    property Embedding: TEmbeddingsRoute read FEmbeddingsRoute;
    /// <summary>
    /// Given a input text, outputs if the model classifies it as violating OpenAI's content policy.
    /// </summary>
    property Moderation: TModerationsRoute read FModerationsRoute;
    /// <summary>
    /// These endpoints describe and provide access to the various engines available in the API.
    /// The Engines endpoints are deprecated.
    /// Please use their replacement, Models, instead.
    /// </summary>
    property Engine: TEnginesRoute read FEnginesRoute;
    /// <summary>
    /// Files are used to upload documents that can be used with features like Fine-tuning.
    /// </summary>
    property &File: TFilesRoute read FFilesRoute;
  end;
  {$WARNINGS ON}

implementation

{ TGPTChatAPI }

constructor TOpenAI.Create(AOwner: TComponent);
begin
  inherited;
  // API
  FAPI := TOpenAIAPI.Create(Self);
  // Routes
  FCompletionsRoute := TCompletionsRoute.CreateRoute(API);
  FEditsRoute := TEditsRoute.CreateRoute(API);
  FImagesRoute := TImagesRoute.CreateRoute(API);
  FModelsRoute := TModelsRoute.CreateRoute(API);
  FEmbeddingsRoute := TEmbeddingsRoute.CreateRoute(API);
  FModerationsRoute := TModerationsRoute.CreateRoute(API);
  FEnginesRoute := TEnginesRoute.CreateRoute(API);
  FFilesRoute := TFilesRoute.CreateRoute(API);
end;

constructor TOpenAI.Create(AOwner: TComponent; const AToken: string);
begin
  Create(AOwner);
  Token := AToken;
end;

destructor TOpenAI.Destroy;
begin
  FCompletionsRoute.Free;
  FEditsRoute.Free;
  FImagesRoute.Free;
  FModelsRoute.Free;
  FEmbeddingsRoute.Free;
  FModerationsRoute.Free;
  FEnginesRoute.Free;
  FFilesRoute.Free;
  inherited;
end;

function TOpenAI.GetToken: string;
begin
  Result := FAPI.Token;
end;

procedure TOpenAI.SetToken(const Value: string);
begin
  FAPI.Token := Value;
end;

end.


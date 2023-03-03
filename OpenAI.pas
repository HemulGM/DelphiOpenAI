unit OpenAI;

interface

uses
  System.SysUtils, System.Classes, OpenAI.Completions, OpenAI.Edits,
  OpenAI.Images, OpenAI.Models, OpenAI.Embeddings, OpenAI.API,
  OpenAI.Moderations, OpenAI.Engines, OpenAI.Files, OpenAI.FineTunes,
  OpenAI.Chat, OpenAI.Audio;

type
  IOpenAI = interface
    ['{F4CF7FB9-9B73-48FB-A3FE-1E98CCEFCAF0}']
    procedure SetToken(const Value: string);
    function GetToken: string;
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetOrganization: string;
    procedure SetOrganization(const Value: string);
    function GetAPI: TOpenAIAPI;
    function GetCompletionsRoute: TCompletionsRoute;
    function GetEditsRoute: TEditsRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModerationsRoute: TModerationsRoute;
    function GetEnginesRoute: TEnginesRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTunesRoute: TFineTunesRoute;
    function GetChatRoute: TChatRoute;
    function GetAudioRoute: TAudioRoute;
    /// <summary>
    /// Direct access to queries
    /// </summary>
    property API: TOpenAIAPI read GetAPI;
    /// <summary>
    /// The OpenAI API uses API keys for authentication.
    /// Visit your API Keys page (https://beta.openai.com/account/api-keys) to retrieve the API key you'll use in your requests.
    /// Remember that your API key is a secret! Do not share it with others or expose it in any client-side code (browsers, apps).
    /// Production requests must be routed through your own backend server where your API key can be securely
    /// loaded from an environment variable or key management service.
    /// </summary>
    property Token: string read GetToken write SetToken;
    /// <summary>
    /// Base Url (https://api.openai.com/v1)
    /// </summary>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
    /// <summary>
    /// For users who belong to multiple organizations, you can pass a header to specify which organization
    /// is used for an API request. Usage from these API requests will count against the specified organization's
    // subscription quota.
    /// </summary>
    property Organization: string read GetOrganization write SetOrganization;
    /// <summary>
    /// Given a prompt, the model will return one or more predicted completions,
    /// and can also return the probabilities of alternative tokens at each position.
    /// </summary>
    property Completion: TCompletionsRoute read GetCompletionsRoute;
    /// <summary>
    /// Given a prompt and an instruction, the model will return an edited version of the prompt.
    /// </summary>
    property Edit: TEditsRoute read GetEditsRoute;
    /// <summary>
    /// Given a prompt and/or an input image, the model will generate a new image.
    /// </summary>
    property Image: TImagesRoute read GetImagesRoute;
    /// <summary>
    /// List and describe the various models available in the API.
    /// You can refer to the Models documentation to understand what models are available and the differences between them.
    /// </summary>
    property Model: TModelsRoute read GetModelsRoute;
    /// <summary>
    /// Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.
    /// </summary>
    property Embedding: TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Given a input text, outputs if the model classifies it as violating OpenAI's content policy.
    /// </summary>
    property Moderation: TModerationsRoute read GetModerationsRoute;
    /// <summary>
    /// These endpoints describe and provide access to the various engines available in the API.
    /// The Engines endpoints are deprecated.
    /// Please use their replacement, Models, instead.
    /// </summary>
    property Engine: TEnginesRoute read GetEnginesRoute;
    /// <summary>
    /// Files are used to upload documents that can be used with features like Fine-tuning.
    /// </summary>
    property &File: TFilesRoute read GetFilesRoute;
    /// <summary>
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    property FineTune: TFineTunesRoute read GetFineTunesRoute;
    /// <summary>
    /// Given a chat conversation, the model will return a chat completion response.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Learn how to turn audio into text.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
  end;

  TOpenAI = class(TInterfacedObject, IOpenAI)
  private
    FAPI: TOpenAIAPI;
    FCompletionsRoute: TCompletionsRoute;
    FEditsRoute: TEditsRoute;
    FImagesRoute: TImagesRoute;
    FModelsRoute: TModelsRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FModerationsRoute: TModerationsRoute;
    FEnginesRoute: TEnginesRoute;
    FFilesRoute: TFilesRoute;
    FFineTunesRoute: TFineTunesRoute;
    FChatRoute: TChatRoute;
    FAudioRoute: TAudioRoute;
    procedure SetToken(const Value: string);
    function GetToken: string;
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetOrganization: string;
    procedure SetOrganization(const Value: string);
    function GetAPI: TOpenAIAPI;
    function GetCompletionsRoute: TCompletionsRoute;
    function GetEditsRoute: TEditsRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModerationsRoute: TModerationsRoute;
    function GetEnginesRoute: TEnginesRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTunesRoute: TFineTunesRoute;
    function GetChatRoute: TChatRoute;
    function GetAudioRoute: TAudioRoute;
  public
    constructor Create; overload;
    constructor Create(const AToken: string); overload;
    destructor Destroy; override;
  public
    /// <summary>
    /// Direct access to queries
    /// </summary>
    property API: TOpenAIAPI read GetAPI;
    /// <summary>
    /// The OpenAI API uses API keys for authentication.
    /// Visit your API Keys page (https://beta.openai.com/account/api-keys) to retrieve the API key you'll use in your requests.
    /// Remember that your API key is a secret! Do not share it with others or expose it in any client-side code (browsers, apps).
    /// Production requests must be routed through your own backend server where your API key can be securely
    /// loaded from an environment variable or key management service.
    /// </summary>
    property Token: string read GetToken write SetToken;
    /// <summary>
    /// Base Url (https://api.openai.com/v1)
    /// </summary>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
    /// <summary>
    /// For users who belong to multiple organizations, you can pass a header to specify which organization
    /// is used for an API request. Usage from these API requests will count against the specified organization's
    // subscription quota.
    /// </summary>
    property Organization: string read GetOrganization write SetOrganization;
  public
    /// <summary>
    /// Given a prompt, the model will return one or more predicted completions,
    /// and can also return the probabilities of alternative tokens at each position.
    /// </summary>
    property Completion: TCompletionsRoute read GetCompletionsRoute;
    /// <summary>
    /// Given a prompt and an instruction, the model will return an edited version of the prompt.
    /// </summary>
    property Edit: TEditsRoute read GetEditsRoute;
    /// <summary>
    /// Given a prompt and/or an input image, the model will generate a new image.
    /// </summary>
    property Image: TImagesRoute read GetImagesRoute;
    /// <summary>
    /// List and describe the various models available in the API.
    /// You can refer to the Models documentation to understand what models are available and the differences between them.
    /// </summary>
    property Model: TModelsRoute read GetModelsRoute;
    /// <summary>
    /// Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.
    /// </summary>
    property Embedding: TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Given a input text, outputs if the model classifies it as violating OpenAI's content policy.
    /// </summary>
    property Moderation: TModerationsRoute read GetModerationsRoute;
    /// <summary>
    /// These endpoints describe and provide access to the various engines available in the API.
    /// The Engines endpoints are deprecated.
    /// Please use their replacement, Models, instead.
    /// </summary>
    property Engine: TEnginesRoute read GetEnginesRoute;
    /// <summary>
    /// Files are used to upload documents that can be used with features like Fine-tuning.
    /// </summary>
    property &File: TFilesRoute read GetFilesRoute;
    /// <summary>
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    property FineTune: TFineTunesRoute read GetFineTunesRoute;
    /// <summary>
    /// Given a chat conversation, the model will return a chat completion response.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Learn how to turn audio into text.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
  end;

  TOpenAIComponent = class(TComponent, IOpenAI)
  private
    FOpenAI: TOpenAI;
    procedure SetToken(const Value: string);
    function GetToken: string;
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetOrganization: string;
    procedure SetOrganization(const Value: string);
    function GetAPI: TOpenAIAPI;
    function GetCompletionsRoute: TCompletionsRoute;
    function GetEditsRoute: TEditsRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModerationsRoute: TModerationsRoute;
    function GetEnginesRoute: TEnginesRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTunesRoute: TFineTunesRoute;
    function GetChatRoute: TChatRoute;
    function GetAudioRoute: TAudioRoute;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    /// <summary>
    /// Direct access to queries
    /// </summary>
    property API: TOpenAIAPI read GetAPI;
    /// <summary>
    /// The OpenAI API uses API keys for authentication.
    /// Visit your API Keys page (https://beta.openai.com/account/api-keys) to retrieve the API key you'll use in your requests.
    /// Remember that your API key is a secret! Do not share it with others or expose it in any client-side code (browsers, apps).
    /// Production requests must be routed through your own backend server where your API key can be securely
    /// loaded from an environment variable or key management service.
    /// </summary>
    property Token: string read GetToken write SetToken;
    /// <summary>
    /// Base Url (https://api.openai.com/v1)
    /// </summary>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
    /// <summary>
    /// For users who belong to multiple organizations, you can pass a header to specify which organization
    /// is used for an API request. Usage from these API requests will count against the specified organization's
    // subscription quota.
    /// </summary>
    property Organization: string read GetOrganization write SetOrganization;
  public
    /// <summary>
    /// Given a prompt, the model will return one or more predicted completions,
    /// and can also return the probabilities of alternative tokens at each position.
    /// </summary>
    property Completion: TCompletionsRoute read GetCompletionsRoute;
    /// <summary>
    /// Given a prompt and an instruction, the model will return an edited version of the prompt.
    /// </summary>
    property Edit: TEditsRoute read GetEditsRoute;
    /// <summary>
    /// Given a prompt and/or an input image, the model will generate a new image.
    /// </summary>
    property Image: TImagesRoute read GetImagesRoute;
    /// <summary>
    /// List and describe the various models available in the API.
    /// You can refer to the Models documentation to understand what models are available and the differences between them.
    /// </summary>
    property Model: TModelsRoute read GetModelsRoute;
    /// <summary>
    /// Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.
    /// </summary>
    property Embedding: TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Given a input text, outputs if the model classifies it as violating OpenAI's content policy.
    /// </summary>
    property Moderation: TModerationsRoute read GetModerationsRoute;
    /// <summary>
    /// These endpoints describe and provide access to the various engines available in the API.
    /// The Engines endpoints are deprecated.
    /// Please use their replacement, Models, instead.
    /// </summary>
    property Engine: TEnginesRoute read GetEnginesRoute;
    /// <summary>
    /// Files are used to upload documents that can be used with features like Fine-tuning.
    /// </summary>
    property &File: TFilesRoute read GetFilesRoute;
    /// <summary>
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    property FineTune: TFineTunesRoute read GetFineTunesRoute;
    /// <summary>
    /// Given a chat conversation, the model will return a chat completion response.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Learn how to turn audio into text.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
  end;

implementation

{ TOpenAI }

constructor TOpenAI.Create;
begin
  inherited;
  FAPI := TOpenAIAPI.Create;
end;

constructor TOpenAI.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor TOpenAI.Destroy;
begin
  if Assigned(FCompletionsRoute) then
    FCompletionsRoute.Free;
  if Assigned(FEditsRoute) then
    FEditsRoute.Free;
  if Assigned(FImagesRoute) then
    FImagesRoute.Free;
  if Assigned(FModelsRoute) then
    FModelsRoute.Free;
  if Assigned(FEmbeddingsRoute) then
    FEmbeddingsRoute.Free;
  if Assigned(FModerationsRoute) then
    FModerationsRoute.Free;
  if Assigned(FEnginesRoute) then
    FEnginesRoute.Free;
  if Assigned(FFilesRoute) then
    FFilesRoute.Free;
  if Assigned(FFineTunesRoute) then
    FFineTunesRoute.Free;
  if Assigned(FChatRoute) then
    FChatRoute.Free;
  if Assigned(FAudioRoute) then
    FAudioRoute.Free;
  FAPI.Free;
  inherited;
end;

function TOpenAI.GetAPI: TOpenAIAPI;
begin
  Result := FAPI;
end;

function TOpenAI.GetAudioRoute: TAudioRoute;
begin
  if not Assigned(FAudioRoute) then
    FAudioRoute := TAudioRoute.CreateRoute(API);
  Result := FAudioRoute;
end;

function TOpenAI.GetBaseUrl: string;
begin
  Result := FAPI.BaseUrl;
end;

function TOpenAI.GetChatRoute: TChatRoute;
begin
  if not Assigned(FChatRoute) then
    FChatRoute := TChatRoute.CreateRoute(API);
  Result := FChatRoute;
end;

function TOpenAI.GetCompletionsRoute: TCompletionsRoute;
begin
  if not Assigned(FCompletionsRoute) then
    FCompletionsRoute := TCompletionsRoute.CreateRoute(API);
  Result := FCompletionsRoute;
end;

function TOpenAI.GetEditsRoute: TEditsRoute;
begin
  if not Assigned(FEditsRoute) then
    FEditsRoute := TEditsRoute.CreateRoute(API);
  Result := FEditsRoute;
end;

function TOpenAI.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  if not Assigned(FEmbeddingsRoute) then
    FEmbeddingsRoute := TEmbeddingsRoute.CreateRoute(API);
  Result := FEmbeddingsRoute;
end;

function TOpenAI.GetEnginesRoute: TEnginesRoute;
begin
  if not Assigned(FEnginesRoute) then
    FEnginesRoute := TEnginesRoute.CreateRoute(API);
  Result := FEnginesRoute;
end;

function TOpenAI.GetFilesRoute: TFilesRoute;
begin
  if not Assigned(FFilesRoute) then
    FFilesRoute := TFilesRoute.CreateRoute(API);
  Result := FFilesRoute;
end;

function TOpenAI.GetFineTunesRoute: TFineTunesRoute;
begin
  if not Assigned(FFineTunesRoute) then
    FFineTunesRoute := TFineTunesRoute.CreateRoute(API);
  Result := FFineTunesRoute;
end;

function TOpenAI.GetImagesRoute: TImagesRoute;
begin
  if not Assigned(FImagesRoute) then
    FImagesRoute := TImagesRoute.CreateRoute(API);
  Result := FImagesRoute;
end;

function TOpenAI.GetModelsRoute: TModelsRoute;
begin
  if not Assigned(FModelsRoute) then
    FModelsRoute := TModelsRoute.CreateRoute(API);
  Result := FModelsRoute;
end;

function TOpenAI.GetModerationsRoute: TModerationsRoute;
begin
  if not Assigned(FModerationsRoute) then
    FModerationsRoute := TModerationsRoute.CreateRoute(API);
  Result := FModerationsRoute;
end;

function TOpenAI.GetOrganization: string;
begin
  Result := FAPI.Organization;
end;

function TOpenAI.GetToken: string;
begin
  Result := FAPI.Token;
end;

procedure TOpenAI.SetBaseUrl(const Value: string);
begin
  FAPI.BaseUrl := Value;
end;

procedure TOpenAI.SetOrganization(const Value: string);
begin
  FAPI.Organization := Value;
end;

procedure TOpenAI.SetToken(const Value: string);
begin
  FAPI.Token := Value;
end;

{ TOpenAIComponent }

constructor TOpenAIComponent.Create(AOwner: TComponent);
begin
  inherited;
  FOpenAI := TOpenAI.Create;
end;

destructor TOpenAIComponent.Destroy;
begin
  FOpenAI.Free;
  inherited;
end;

function TOpenAIComponent.GetAPI: TOpenAIAPI;
begin
  Result := FOpenAI.API;
end;

function TOpenAIComponent.GetAudioRoute: TAudioRoute;
begin
  Result := FOpenAI.GetAudioRoute;
end;

function TOpenAIComponent.GetBaseUrl: string;
begin
  Result := FOpenAI.GetBaseUrl;
end;

function TOpenAIComponent.GetChatRoute: TChatRoute;
begin
  Result := FOpenAI.GetChatRoute;
end;

function TOpenAIComponent.GetCompletionsRoute: TCompletionsRoute;
begin
  Result := FOpenAI.GetCompletionsRoute;
end;

function TOpenAIComponent.GetEditsRoute: TEditsRoute;
begin
  Result := FOpenAI.GetEditsRoute;
end;

function TOpenAIComponent.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  Result := FOpenAI.GetEmbeddingsRoute;
end;

function TOpenAIComponent.GetEnginesRoute: TEnginesRoute;
begin
  Result := FOpenAI.GetEnginesRoute;
end;

function TOpenAIComponent.GetFilesRoute: TFilesRoute;
begin
  Result := FOpenAI.GetFilesRoute;
end;

function TOpenAIComponent.GetFineTunesRoute: TFineTunesRoute;
begin
  Result := FOpenAI.GetFineTunesRoute;
end;

function TOpenAIComponent.GetImagesRoute: TImagesRoute;
begin
  Result := FOpenAI.GetImagesRoute;
end;

function TOpenAIComponent.GetModelsRoute: TModelsRoute;
begin
  Result := FOpenAI.GetModelsRoute;
end;

function TOpenAIComponent.GetModerationsRoute: TModerationsRoute;
begin
  Result := FOpenAI.GetModerationsRoute;
end;

function TOpenAIComponent.GetOrganization: string;
begin
  Result := FOpenAI.GetOrganization;
end;

function TOpenAIComponent.GetToken: string;
begin
  Result := FOpenAI.GetToken;
end;

procedure TOpenAIComponent.SetBaseUrl(const Value: string);
begin
  FOpenAI.SetBaseUrl(Value);
end;

procedure TOpenAIComponent.SetOrganization(const Value: string);
begin
  FOpenAI.SetOrganization(Value);
end;

procedure TOpenAIComponent.SetToken(const Value: string);
begin
  FOpenAI.SetToken(Value);
end;

end.


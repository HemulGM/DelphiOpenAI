unit OpenAI;

interface

uses
  System.SysUtils, System.Classes, OpenAI.Completions, OpenAI.Edits,
  OpenAI.Images, OpenAI.Models, OpenAI.Embeddings, OpenAI.API,
  OpenAI.Moderations, OpenAI.Engines, OpenAI.Files, OpenAI.FineTunes,
  OpenAI.Chat, OpenAI.Audio, OpenAI.FineTuning, System.Net.URLClient,
  OpenAI.Assistants;

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
    function GetFineTuningRoute: TFineTuningRoute;
    function GetChatRoute: TChatRoute;
    function GetAudioRoute: TAudioRoute;
    function GetAssistantsRoute: TAssistantsRoute;
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
    /// subscription quota.
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
    /// Manage legacy fine-tuning jobs to tailor a model to your specific training data.
    /// We recommend transitioning to the updating FineTuning API.
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    property FineTune: TFineTunesRoute read GetFineTunesRoute;
    /// <summary>
    /// Manage fine-tuning jobs to tailor a model to your specific training data.
    /// </summary>
    property FineTuning: TFineTuningRoute read GetFineTuningRoute;
    /// <summary>
    /// Given a chat conversation, the model will return a chat completion response.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Learn how to turn audio into text.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
    /// <summary>
    /// Build assistants that can call models and use tools to perform tasks.
    /// </summary>
    property Assistants: TAssistantsRoute read GetAssistantsRoute;
  end;

  TOpenAI = class(TInterfacedObject, IOpenAI)
  private
    FAPI: TOpenAIAPI;
    FCompletionsRoute: TCompletionsRoute;
    FEditsRoute: TEditsRoute;
    FImagesRoute: TImagesRoute;
    FImagesAzureRoute: TImagesAzureRoute;
    FModelsRoute: TModelsRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FModerationsRoute: TModerationsRoute;
    FEnginesRoute: TEnginesRoute;
    FFilesRoute: TFilesRoute;
    FFineTunesRoute: TFineTunesRoute;
    FFineTuningRoute: TFineTuningRoute;
    FChatRoute: TChatRoute;
    FAudioRoute: TAudioRoute;
    FAssistantsRoute: TAssistantsRoute;
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
    function GetAssistantsRoute: TAssistantsRoute;
    function GetAzureAPIVersion: string;
    function GetAzureDeployment: string;
    function GetIsAzure: Boolean;
    procedure SetAzureAPIVersion(const Value: string);
    procedure SetAzureDeployment(const Value: string);
    procedure SetIsAzure(const Value: Boolean);
    function GetImagesAzureRoute: TImagesAzureRoute;
    function GetFineTuningRoute: TFineTuningRoute;
  public
    constructor Create; overload;
    constructor Create(const AToken: string); overload;
    destructor Destroy; override;
  public
    /// <summary>
    /// Direct access to API
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
    /// subscription quota.
    /// </summary>
    property Organization: string read GetOrganization write SetOrganization;

    property IsAzure: Boolean read GetIsAzure write SetIsAzure;
    property AzureApiVersion: string read GetAzureAPIVersion write SetAzureAPIVersion;
    property AzureDeployment: string read GetAzureDeployment write SetAzureDeployment;
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
    /// Given a prompt and/or an input image, the model will generate a new image.
    /// </summary>
    property ImageAzure: TImagesAzureRoute read GetImagesAzureRoute;
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
    /// Manage legacy fine-tuning jobs to tailor a model to your specific training data.
    /// We recommend transitioning to the updating FineTuning API.
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    property FineTune: TFineTunesRoute read GetFineTunesRoute;
    /// <summary>
    /// Manage fine-tuning jobs to tailor a model to your specific training data.
    /// </summary>
    property FineTuning: TFineTuningRoute read GetFineTuningRoute;
    /// <summary>
    /// Given a chat conversation, the model will return a chat completion response.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Learn how to turn audio into text.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
    /// <summary>
    /// Build assistants that can call models and use tools to perform tasks.
    /// </summary>
    property Assistants: TAssistantsRoute read GetAssistantsRoute;
  end;

  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TOpenAIComponent = class(TComponent, IOpenAI)
  private
    type
      THTTPProxy = class(TPersistent)
      private
        FOwner: TOpenAIComponent;
        procedure SetIP(const Value: string);
        procedure SetPassword(const Value: string);
        procedure SetPort(const Value: Integer);
        procedure SetUserName(const Value: string);
        function GetIP: string;
        function GetPassword: string;
        function GetPort: Integer;
        function GetUserName: string;
      public
        constructor Create(AOwner: TOpenAIComponent);
        procedure SetProxy(AIP: string; APort: Integer; AUserName: string = ''; APassword: string = '');
      published
        property IP: string read GetIP write SetIP;
        property Port: Integer read GetPort write SetPort;
        property UserName: string read GetUserName write SetUserName;
        property Password: string read GetPassword write SetPassword;
      end;


      THTTPHeader = class(TCollectionItem)
      private
        FName: string;
        FValue: string;
        procedure SetName(const Value: string);
        procedure SetValue(const Value: string);
      published
        property Name: string read FName write SetName;
        property Value: string read FValue write SetValue;
      end;


      THTTPHeaders = class(TOwnedCollection)
      private
        FOnChange: TNotifyEvent;
        procedure SetOnChange(const Value: TNotifyEvent);
      protected
        procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
        property OnChange: TNotifyEvent read FOnChange write SetOnChange;
      end;
  private
    FOpenAI: TOpenAI;
    FProxy: THTTPProxy;
    FCustomHeaders: THTTPHeaders;
    procedure FOnChangeHeaders(Sender: TObject);
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
    function GetAssistantsRoute: TAssistantsRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetConnectionTimeout: Integer;
    function GetResponseTimeout: Integer;
    function GetSendTimeout: Integer;
    procedure SetConnectionTimeout(const Value: Integer);
    procedure SetResponseTimeout(const Value: Integer);
    procedure SetSendTimeout(const Value: Integer);
    function GetAzureAPIVersion: string;
    function GetAzureDeployment: string;
    function GetIsAzure: Boolean;
    procedure SetAzureAPIVersion(const Value: string);
    procedure SetAzureDeployment(const Value: string);
    procedure SetIsAzure(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    /// <summary>
    /// Direct access to queries
    /// </summary>
    property API: TOpenAIAPI read GetAPI;
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
    /// Manage legacy fine-tuning jobs to tailor a model to your specific training data.
    /// We recommend transitioning to the updating FineTuning API.
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    property FineTune: TFineTunesRoute read GetFineTunesRoute;
    /// <summary>
    /// Manage fine-tuning jobs to tailor a model to your specific training data.
    /// </summary>
    property FineTuning: TFineTuningRoute read GetFineTuningRoute;
    /// <summary>
    /// Given a chat conversation, the model will return a chat completion response.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Learn how to turn audio into text.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
    /// <summary>
    /// Build assistants that can call models and use tools to perform tasks.
    /// </summary>
    property Assistants: TAssistantsRoute read GetAssistantsRoute;
  published
    /// <summary>
    /// The OpenAI API uses API keys for authentication.
    /// Visit your API Keys page (https://beta.openai.com/account/api-keys) to retrieve the API key you'll use in your requests.
    /// Remember that your API key is a secret! Do not share it with others or expose it in any client-side code (browsers, apps).
    /// Production requests must be routed through your own backend server where your API key can be securely
    /// loaded from an environment variable or key management service.
    /// </summary>
    /// <seealso>https://beta.openai.com/account/api-keys</seealso>
    property Token: string read GetToken write SetToken;
    /// <summary>
    /// Base Url (https://api.openai.com/v1)
    /// </summary>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
    /// <summary>
    /// For users who belong to multiple organizations, you can pass a header to specify which organization
    /// is used for an API request. Usage from these API requests will count against the specified organization's
    /// subscription quota.
    /// </summary>
    property Organization: string read GetOrganization write SetOrganization;
    /// <summary>
    /// Http client proxy
    /// </summary>
    property Proxy: THTTPProxy read FProxy;
    /// <summary> Property to set/get the ConnectionTimeout. Value is in milliseconds.
    /// -1 - Infinite timeout. 0 - platform specific timeout. Supported by Windows, Linux, Android platforms.
    /// </summary>
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    /// <summary> Property to set/get the SendTimeout. Value is in milliseconds.
    /// -1 - Infinite timeout. 0 - platform specific timeout. Supported by Windows, macOS platforms.
    /// </summary>
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    /// <summary> Property to set/get the ResponseTimeout. Value is in milliseconds.
    /// -1 - Infinite timeout. 0 - platform specific timeout. Supported by all platforms.
    /// </summary>
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;

    property IsAzure: Boolean read GetIsAzure write SetIsAzure;
    property AzureApiVersion: string read GetAzureAPIVersion write SetAzureAPIVersion;
    property AzureDeployment: string read GetAzureDeployment write SetAzureDeployment;
    property CustomHeaders: THTTPHeaders read FCustomHeaders;
  end;

  TOpenAIClient = class(TOpenAIComponent)
  published
    /// <summary>
    /// The OpenAI API uses API keys for authentication.
    /// Visit your API Keys page (https://beta.openai.com/account/api-keys) to retrieve the API key you'll use in your requests.
    /// Remember that your API key is a secret! Do not share it with others or expose it in any client-side code (browsers, apps).
    /// Production requests must be routed through your own backend server where your API key can be securely
    /// loaded from an environment variable or key management service.
    /// </summary>
    /// <seealso>https://beta.openai.com/account/api-keys</seealso>
    property Token;
    /// <summary>
    /// Base Url (https://api.openai.com/v1)
    /// </summary>
    property BaseURL;
    /// <summary>
    /// For users who belong to multiple organizations, you can pass a header to specify which organization
    /// is used for an API request. Usage from these API requests will count against the specified organization's
    /// subscription quota.
    /// </summary>
    property Organization;
    /// <summary>
    /// Http client proxy
    /// </summary>
    property Proxy;
    /// <summary> Property to set/get the ConnectionTimeout. Value is in milliseconds.
    /// -1 - Infinite timeout. 0 - platform specific timeout. Supported by Windows, Linux, Android platforms.
    /// </summary>
    property ConnectionTimeout default TURLClient.DefaultConnectionTimeout;
    /// <summary> Property to set/get the SendTimeout. Value is in milliseconds.
    /// -1 - Infinite timeout. 0 - platform specific timeout. Supported by Windows, macOS platforms.
    /// </summary>
    property SendTimeout default TURLClient.DefaultSendTimeout;
    /// <summary> Property to set/get the ResponseTimeout. Value is in milliseconds.
    /// -1 - Infinite timeout. 0 - platform specific timeout. Supported by all platforms.
    /// </summary>
    property ResponseTimeout default TURLClient.DefaultResponseTimeout;
    property IsAzure default False;
    property AzureApiVersion;
    property AzureDeployment;
    property CustomHeaders;
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
  FCompletionsRoute.Free;
  FEditsRoute.Free;
  FImagesRoute.Free;
  FImagesAzureRoute.Free;
  FModelsRoute.Free;
  FEmbeddingsRoute.Free;
  FModerationsRoute.Free;
  FEnginesRoute.Free;
  FFilesRoute.Free;
  FFineTunesRoute.Free;
  FFineTuningRoute.Free;
  FChatRoute.Free;
  FAudioRoute.Free;
  FAPI.Free;
  inherited;
end;

function TOpenAI.GetAPI: TOpenAIAPI;
begin
  Result := FAPI;
end;

function TOpenAI.GetAssistantsRoute: TAssistantsRoute;
begin
  if not Assigned(FAssistantsRoute) then
    FAssistantsRoute := TAssistantsRoute.CreateRoute(API);
  Result := FAssistantsRoute;
end;

function TOpenAI.GetAudioRoute: TAudioRoute;
begin
  if not Assigned(FAudioRoute) then
    FAudioRoute := TAudioRoute.CreateRoute(API);
  Result := FAudioRoute;
end;

function TOpenAI.GetAzureAPIVersion: string;
begin
  Result := FAPI.AzureApiVersion;
end;

function TOpenAI.GetAzureDeployment: string;
begin
  Result := FAPI.AzureDeployment;
end;

function TOpenAI.GetBaseUrl: string;
begin
  Result := FAPI.BaseURL;
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

function TOpenAI.GetFineTuningRoute: TFineTuningRoute;
begin
  if not Assigned(FFineTuningRoute) then
    FFineTuningRoute := TFineTuningRoute.CreateRoute(API);
  Result := FFineTuningRoute;
end;

function TOpenAI.GetImagesAzureRoute: TImagesAzureRoute;
begin
  if not Assigned(FImagesAzureRoute) then
    FImagesAzureRoute := TImagesAzureRoute.CreateRoute(API);
  Result := FImagesAzureRoute;
end;

function TOpenAI.GetImagesRoute: TImagesRoute;
begin
  if not Assigned(FImagesRoute) then
    FImagesRoute := TImagesRoute.CreateRoute(API);
  Result := FImagesRoute;
end;

function TOpenAI.GetIsAzure: Boolean;
begin
  Result := FAPI.IsAzure;
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

procedure TOpenAI.SetAzureAPIVersion(const Value: string);
begin
  FAPI.AzureApiVersion := Value;
end;

procedure TOpenAI.SetAzureDeployment(const Value: string);
begin
  FAPI.AzureDeployment := Value;
end;

procedure TOpenAI.SetBaseUrl(const Value: string);
begin
  FAPI.BaseURL := Value;
end;

procedure TOpenAI.SetIsAzure(const Value: Boolean);
begin
  FAPI.IsAzure := Value;
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
  FCustomHeaders := THTTPHeaders.Create(Self, THTTPHeader);
  FCustomHeaders.OnChange := FOnChangeHeaders;
  FProxy := THTTPProxy.Create(Self);
end;

destructor TOpenAIComponent.Destroy;
begin
  FOpenAI.Free;
  FCustomHeaders.Free;
  FProxy.Free;
  inherited;
end;

procedure TOpenAIComponent.FOnChangeHeaders(Sender: TObject);
var
  i: Integer;
  FHeaders: TNetHeaders;
begin
  for i := 0 to FCustomHeaders.Count - 1 do
    FHeaders := FHeaders + [TNameValuePair.Create(
      THTTPHeader(FCustomHeaders.Items[i]).Name,
      THTTPHeader(FCustomHeaders.Items[i]).Value)];
  API.CustomHeaders := FHeaders;
end;

function TOpenAIComponent.GetAPI: TOpenAIAPI;
begin
  Result := FOpenAI.API;
end;

function TOpenAIComponent.GetAssistantsRoute: TAssistantsRoute;
begin
  Result := FOpenAI.GetAssistantsRoute;
end;

function TOpenAIComponent.GetAudioRoute: TAudioRoute;
begin
  Result := FOpenAI.GetAudioRoute;
end;

function TOpenAIComponent.GetAzureAPIVersion: string;
begin
  Result := FOpenAI.API.AzureApiVersion;
end;

function TOpenAIComponent.GetAzureDeployment: string;
begin
  Result := FOpenAI.API.AzureDeployment;
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

function TOpenAIComponent.GetConnectionTimeout: Integer;
begin
  Result := FOpenAI.API.ConnectionTimeout;
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

function TOpenAIComponent.GetFineTuningRoute: TFineTuningRoute;
begin
  Result := FOpenAI.GetFineTuningRoute;
end;

function TOpenAIComponent.GetImagesRoute: TImagesRoute;
begin
  Result := FOpenAI.GetImagesRoute;
end;

function TOpenAIComponent.GetIsAzure: Boolean;
begin
  Result := FOpenAI.API.IsAzure;
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

function TOpenAIComponent.GetResponseTimeout: Integer;
begin
  Result := FOpenAI.API.ResponseTimeout;
end;

function TOpenAIComponent.GetSendTimeout: Integer;
begin
  Result := FOpenAI.API.SendTimeout;
end;

function TOpenAIComponent.GetToken: string;
begin
  Result := FOpenAI.GetToken;
end;

procedure TOpenAIComponent.SetAzureAPIVersion(const Value: string);
begin
  FOpenAI.API.AzureApiVersion := Value;
end;

procedure TOpenAIComponent.SetAzureDeployment(const Value: string);
begin
  FOpenAI.API.AzureDeployment := Value;
end;

procedure TOpenAIComponent.SetBaseUrl(const Value: string);
begin
  FOpenAI.SetBaseUrl(Value);
end;

procedure TOpenAIComponent.SetConnectionTimeout(const Value: Integer);
begin
  FOpenAI.API.ConnectionTimeout := Value;
end;

procedure TOpenAIComponent.SetIsAzure(const Value: Boolean);
begin
  FOpenAI.API.IsAzure := Value;
end;

procedure TOpenAIComponent.SetOrganization(const Value: string);
begin
  FOpenAI.SetOrganization(Value);
end;

procedure TOpenAIComponent.SetResponseTimeout(const Value: Integer);
begin
  FOpenAI.API.ResponseTimeout := Value;
end;

procedure TOpenAIComponent.SetSendTimeout(const Value: Integer);
begin
  FOpenAI.API.SendTimeout := Value;
end;

procedure TOpenAIComponent.SetToken(const Value: string);
begin
  FOpenAI.SetToken(Value);
end;

{ TOpenAIComponent.THTTPProxy }

constructor TOpenAIComponent.THTTPProxy.Create(AOwner: TOpenAIComponent);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TOpenAIComponent.THTTPProxy.GetIP: string;
begin
  Result := FOwner.API.ProxySettings.Host;
end;

function TOpenAIComponent.THTTPProxy.GetPassword: string;
begin
  Result := FOwner.API.ProxySettings.Password;
end;

function TOpenAIComponent.THTTPProxy.GetPort: Integer;
begin
  Result := FOwner.API.ProxySettings.Port;
end;

function TOpenAIComponent.THTTPProxy.GetUserName: string;
begin
  Result := FOwner.API.ProxySettings.UserName;
end;

procedure TOpenAIComponent.THTTPProxy.SetIP(const Value: string);
var
  Proxy: TProxySettings;
begin
  Proxy := FOwner.API.ProxySettings;
  Proxy.Host := Value;
  FOwner.API.ProxySettings := Proxy;
end;

procedure TOpenAIComponent.THTTPProxy.SetPassword(const Value: string);
var
  Proxy: TProxySettings;
begin
  Proxy := FOwner.API.ProxySettings;
  Proxy.Password := Value;
  FOwner.API.ProxySettings := Proxy;
end;

procedure TOpenAIComponent.THTTPProxy.SetPort(const Value: Integer);
var
  Proxy: TProxySettings;
begin
  Proxy := FOwner.API.ProxySettings;
  Proxy.Port := Value;
  FOwner.API.ProxySettings := Proxy;
end;

procedure TOpenAIComponent.THTTPProxy.SetProxy(AIP: string; APort: Integer; AUserName, APassword: string);
begin
  IP := AIP;
  Port := APort;
  Username := AUserName;
  Password := APassword;
end;

procedure TOpenAIComponent.THTTPProxy.SetUserName(const Value: string);
var
  Proxy: TProxySettings;
begin
  Proxy := FOwner.API.ProxySettings;
  Proxy.UserName := Value;
  FOwner.API.ProxySettings := Proxy;
end;

{ TOpenAIComponent.THTTPHeaders }

procedure TOpenAIComponent.THTTPHeaders.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TOpenAIComponent.THTTPHeaders.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

{ TOpenAIComponent.THTTPHeader }

procedure TOpenAIComponent.THTTPHeader.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TOpenAIComponent.THTTPHeader.SetValue(const Value: string);
begin
  FValue := Value;
end;

end.


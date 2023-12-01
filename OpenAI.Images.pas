unit OpenAI.Images;

interface

uses
  System.Classes, System.SysUtils, System.Net.Mime, OpenAI.API.Params,
  OpenAI.API;

{$SCOPEDENUMS ON}

type
  TImageResponseFormat = (Url, B64Json);

  TImageResponseFormatHelper = record helper for TImageResponseFormat
    function ToString: string;
  end;

  {             |       dall-e-2         |          dall-e-3         | }
  TImageSize = (s256x256, s512x512, s1024x1024, s1792x1024, s1024x1792);

  TImageSizeHelper = record helper for TImageSize
    function ToString: string;
  end;

  TImageCreateParams = class(TJSONParam)
    /// <summary>
    /// A text description of the desired image(s).
    /// The maximum length is 1000 characters for "dall-e-2" and 4000 characters for "dall-e-3".
    /// </summary>
    function Prompt(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The model to use for image generation.  Defaults to "dall-e-2".
    /// </summary>
    function Model(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10. For "dall-e-3", only "n=1" is supported.
    /// </summary>
    /// <summary>
    function N(const Value: Integer = 1): TImageCreateParams;
    /// The quality of the image that will be generated.
    /// "hd" creates images with finer details and greater consistency across the image.
    /// This param is only supported for "dall-e-3".
    /// </summary>
    function Quality(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024" for "dall-e-2".
    /// Must be one of "1024x1024", "1792x1024", or "1024x1792" for "dall-e-3" models.
    /// </summary>
    function Size(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024" for "dall-e-2".
    /// Must be one of "1024x1024", "1792x1024", or "1024x1792" for "dall-e-3" models.
    /// </summary>
    function Size(const Value: TImageSize = TImageSize.s1024x1024): TImageCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of "url" or "b64_json"
    /// </summary>
    function ResponseFormat(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of "url" or "b64_json"
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageCreateParams; overload;
    /// <summary>
    /// The style of the generated images. Must be one of "vivid" or "natural".
    /// Vivid causes the model to lean towards generating hyper-real and dramatic images.
    /// Natural causes the model to produce more natural, less hyper-real looking images.
    /// This param is only supported for "dall-e-3". Defaults to "vivid".
    /// </summary>
    function Style(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids</seealso>
    function User(const Value: string): TImageCreateParams;
  end;

  TImageAzureCreateParams = class(TJSONParam)
    /// <summary>
    /// A text description of the desired image(s) for the azure-environment. The maximum length is 1000 characters.
    /// </summary>
    function Caption(const Value: string): TImageAzureCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Resolution(const Value: string): TImageAzureCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Resolution(const Value: TImageSize = TImageSize.s256x256): TImageAzureCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: string): TImageAzureCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageAzureCreateParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageAzureCreateParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids</seealso>
    function User(const Value: string): TImageAzureCreateParams;
  end;

  TImageEditParams = class(TMultipartFormData)
    /// <summary>
    /// The image to edit. Must be a valid PNG file, less than 4MB, and square.
    /// If mask is not provided, image must have transparency, which will be used as the mask.
    /// </summary>
    function Image(const FileName: TFileName): TImageEditParams; overload;
    /// <summary>
    /// The image to edit. Must be a valid PNG file, less than 4MB, and square.
    /// If mask is not provided, image must have transparency, which will be used as the mask.
    /// </summary>
    function Image(const Stream: TStream; const FileName: TFileName): TImageEditParams; overload;
    /// <summary>
    /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited.
    /// Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
    /// </summary>
    function Mask(const FileName: TFileName): TImageEditParams; overload;
    /// <summary>
    /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited.
    /// Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
    /// </summary>
    function Mask(const Stream: TStream; const FileName: TFileName): TImageEditParams; overload;
    /// <summary>
    /// The model to use for image generation. Only "dall-e-2" is supported at this time.
    /// </summary>
    function Model(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// A text description of the desired image(s). The maximum length is 1000 characters.
    /// </summary>
    function Prompt(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageEditParams;
    /// <summary>
    /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024".
    /// </summary>
    function Size(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024".
    /// </summary>
    function Size(const Value: TImageSize = TImageSize.s256x256): TImageEditParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of "url" or "b64_json".
    /// </summary>
    function ResponseFormat(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of "url" or "b64_json".
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageEditParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids</seealso>
    function User(const Value: string): TImageEditParams;
    constructor Create; reintroduce;
  end;

  TImageVariationParams = class(TMultipartFormData)
    /// <summary>
    /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
    /// </summary>
    function Image(const FileName: TFileName): TImageVariationParams; overload;
    /// <summary>
    /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
    /// </summary>
    function Image(const Stream: TStream; const FileName: TFileName): TImageVariationParams; overload;
    /// <summary>
    /// The model to use for image generation. Only "dall-e-2" is supported at this time.
    /// </summary>
    function Model(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10. For "dall-e-3", only "n=1" is supported.
    /// </summary>
    function N(const Value: Integer = 1): TImageVariationParams;
    /// <summary>
    /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024".
    /// </summary>
    function Size(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024".
    /// </summary>
    function Size(const Value: TImageSize = TImageSize.s256x256): TImageVariationParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of "url" or "b64_json".
    /// </summary>
    function ResponseFormat(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of "url" or "b64_json".
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageVariationParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids</seealso>
    function User(const Value: string): TImageVariationParams;
    constructor Create; reintroduce;
  end;

  /// <summary>
  /// Represents the url or the content of an image generated by the OpenAI API.
  /// </summary>
  TImageData = class
  private
    FUrl: string;
    FB64_json: string;
    FRevised_prompt: string;
  public
    /// <summary>
    /// The URL of the generated image, if response_format is url (default).
    /// </summary>
    property Url: string read FUrl write FUrl;
    /// <summary>
    /// The base64-encoded JSON of the generated image, if response_format is b64_json.
    /// </summary>
    property B64Json: string read FB64_json write FB64_json;
    /// <summary>
    /// The prompt that was used to generate the image, if there was any revision to the prompt.
    /// </summary>
    property RevisedPrompt: string read FRevised_prompt write FRevised_prompt;
  end;

  TImageGenerations = class
  private
    FData: TArray<TImageData>;
    FCreated: Int64;
  public
    property Data: TArray<TImageData> read FData write FData;
    property Created: Int64 read FCreated write FCreated;
    destructor Destroy; override;
  end;

  TAzureError = class
  private
    FCode: string;
    FMessage: string;
  public
    property Code: string read FCode write FCode;
    property Message: string read FMessage write FMessage;
  end;

  TAzureImageData = class
  private
    FCaption: string;
    FContentURL: string;
    FContentURLExpiresAt: string;
    FCreatedDateTime: string;
  public
    property Caption: string read FCaption write FCaption;
    property ContentURL: string read FContentURL write FContentURL;
    property ContentURLExpiresAt: string read FContentURLExpiresAt write FContentURLExpiresAt;
    property CreatedDateTime: string read FCreatedDateTime write FCreatedDateTime;
  end;

  TAzureImageResponse = class
  private
    FID: string;
    FStatus: string;
    FResult: TAzureImageData;
    FError: TAzureError;
  public
    destructor Destroy; override;
    property Result: TAzureImageData read FResult write FResult;
    property Error: TAzureError read FError write FError;
    property ID: string read FID write FID;
    property Status: string read FStatus write FStatus;
  end;

  TImagesRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates an image given a prompt.
    /// </summary>
    function Create(ParamProc: TProc<TImageCreateParams>): TImageGenerations;
    /// <summary>
    /// Creates an edited or extended image given an original image and a prompt.
    /// </summary>
    function Edit(ParamProc: TProc<TImageEditParams>): TImageGenerations;
    /// <summary>
    /// Creates a variation of a given image.
    /// </summary>
    function Variation(ParamProc: TProc<TImageVariationParams>): TImageGenerations;
  end;

  TCancelCallback = reference to procedure(var Cancel: Boolean);

  TImagesAzureRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates an image given a prompt.
    /// </summary>
    function Create(ParamProc: TProc<TImageAzureCreateParams>; CancelCallback: TCancelCallback = nil): TAzureImageResponse;
  end;

const
  AzureFailed = 'Failed';
  AzureSuccessed = 'Succeeded';

implementation

{ TImagesRoute }

function TImagesRoute.Create(ParamProc: TProc<TImageCreateParams>): TImageGenerations;
begin
  Result := API.Post<TImageGenerations, TImageCreateParams>('images/generations', ParamProc);
end;

function TImagesRoute.Edit(ParamProc: TProc<TImageEditParams>): TImageGenerations;
begin
  Result := API.PostForm<TImageGenerations, TImageEditParams>('images/edits', ParamProc);
end;

function TImagesRoute.Variation(ParamProc: TProc<TImageVariationParams>): TImageGenerations;
begin
  Result := API.PostForm<TImageGenerations, TImageVariationParams>('images/variations', ParamProc);
end;

{ TImageGenerations }

destructor TImageGenerations.Destroy;
var
  Item: TImageData;
begin
  for Item in FData do
    Item.Free;
  inherited;
end;

{ TImageCreateParams }

function TImageCreateParams.Model(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('model', Value));
end;

function TImageCreateParams.N(const Value: Integer): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('n', Value));
end;

function TImageCreateParams.Prompt(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('prompt', Value));
end;

function TImageCreateParams.Quality(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('quality', Value));
end;

function TImageCreateParams.ResponseFormat(const Value: TImageResponseFormat): TImageCreateParams;
begin
  Result := ResponseFormat(Value.ToString);
end;

function TImageCreateParams.Size(const Value: TImageSize): TImageCreateParams;
begin
  Result := Size(Value.ToString);
end;

function TImageCreateParams.Style(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('style', Value));
end;

function TImageCreateParams.Size(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('size', Value));
end;

function TImageCreateParams.ResponseFormat(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('response_format', Value));
end;

function TImageCreateParams.User(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('user', Value));
end;

{ TImageEditParams }

function TImageEditParams.Image(const FileName: TFileName): TImageEditParams;
begin
  AddFile('image', FileName);
  Result := Self;
end;

constructor TImageEditParams.Create;
begin
  inherited Create(true);
end;

function TImageEditParams.Image(const Stream: TStream; const FileName: TFileName): TImageEditParams;
begin
  AddStream('image', Stream, FileName);
  Result := Self;
end;

function TImageEditParams.Mask(const Stream: TStream; const FileName: TFileName): TImageEditParams;
begin
  AddStream('mask', Stream, FileName);
  Result := Self;
end;

function TImageEditParams.Model(const Value: string): TImageEditParams;
begin
  AddFile('model', Value);
  Result := Self;
end;

function TImageEditParams.Mask(const FileName: TFileName): TImageEditParams;
begin
  AddFile('mask', FileName);
  Result := Self;
end;

function TImageEditParams.N(const Value: Integer): TImageEditParams;
begin
  AddField('n', Value.ToString);
  Result := Self;
end;

function TImageEditParams.Prompt(const Value: string): TImageEditParams;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TImageEditParams.ResponseFormat(const Value: string): TImageEditParams;
begin
  AddField('response_format', Value);
  Result := Self;
end;

function TImageEditParams.ResponseFormat(const Value: TImageResponseFormat): TImageEditParams;
begin
  AddField('response_format', Value.ToString);
  Result := Self;
end;

function TImageEditParams.Size(const Value: string): TImageEditParams;
begin
  AddField('size', Value);
  Result := Self;
end;

function TImageEditParams.Size(const Value: TImageSize): TImageEditParams;
begin
  AddField('size', Value.ToString);
  Result := Self;
end;

function TImageEditParams.User(const Value: string): TImageEditParams;
begin
  AddField('user', Value);
  Result := Self;
end;

{ TImageVariationParams }

function TImageVariationParams.Image(const FileName: TFileName): TImageVariationParams;
begin
  AddFile('image', FileName);
  Result := Self;
end;

constructor TImageVariationParams.Create;
begin
  inherited Create(true);
end;

function TImageVariationParams.Image(const Stream: TStream; const FileName: TFileName): TImageVariationParams;
begin
  AddStream('image', Stream, FileName);
  Result := Self;
end;

function TImageVariationParams.Model(const Value: string): TImageVariationParams;
begin
  AddField('model', Value);
  Result := Self;
end;

function TImageVariationParams.N(const Value: Integer): TImageVariationParams;
begin
  AddField('n', Value.ToString);
  Result := Self;
end;

function TImageVariationParams.ResponseFormat(const Value: string): TImageVariationParams;
begin
  AddField('response_format', Value);
  Result := Self;
end;

function TImageVariationParams.ResponseFormat(const Value: TImageResponseFormat): TImageVariationParams;
begin
  AddField('response_format', Value.ToString);
  Result := Self;
end;

function TImageVariationParams.Size(const Value: string): TImageVariationParams;
begin
  AddField('size', Value);
  Result := Self;
end;

function TImageVariationParams.Size(const Value: TImageSize = TImageSize.s256x256): TImageVariationParams;
begin
  AddField('size', Value.ToString);
  Result := Self;
end;

function TImageVariationParams.User(const Value: string): TImageVariationParams;
begin
  AddField('user', Value);
  Result := Self;
end;

{ TImageResponseFormatHelper }

function TImageResponseFormatHelper.ToString: string;
begin
  case Self of
    TImageResponseFormat.Url:
      Result := 'url';
    TImageResponseFormat.B64Json:
      Result := 'b64_json';
  end;
end;

{ TImageSizeHelper }

function TImageSizeHelper.ToString: string;
begin
  case Self of
    TImageSize.s256x256:
      Result := '256x256';
    TImageSize.s512x512:
      Result := '512x512';
    TImageSize.s1024x1024:
      Result := '1024x1024';
    TImageSize.s1792x1024:
      Result := '1792x1024';
    TImageSize.s1024x1792:
      Result := '1024x1792';
  end;
end;

{ TAzureImageResponse }

destructor TAzureImageResponse.Destroy;
begin
  if Assigned(FResult) then
    FResult.Free;
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

{ TImagesAzureRoute }

function TImagesAzureRoute.Create(ParamProc: TProc<TImageAzureCreateParams>; CancelCallback: TCancelCallback): TAzureImageResponse;
const
  Timeout: Integer = 20000; // 20 second timeout
  PollInterval: Integer = 1000; // poll for image once per second
var
  StartTime: UInt64;
  Cancel: Boolean;
  OperationID: string;
begin
  // First place the task with POST
  Result := API.Post<TAzureImageResponse, TImageAzureCreateParams>('text-to-image', ParamProc);

  // Check if we got a valid id - current azure documentation is not that precise here if we always get "NotStarted".
  // Otherwise we get "failed" and in the "error"-property we can find "code" and "message" of the error
  if (Result.ID = '') or (Result.Status = AzureFailed) then
    Exit;

  // Timeout timestamp
  {$IF CompilerVersion > 34}
  StartTime := TThread.GetTickCount64;
  {$ELSE}
  StartTime := TThread.GetTickCount;
  {$ENDIF}
  Cancel := False;

  OperationID := Result.ID;

  // Repeat GET requesting the operations-endpoint until we have a "succeeded" response
  while not Cancel do
  begin
    Result.Free;
    Result := API.Get<TAzureImageResponse>('text-to-image/operations/' + OperationID);
    // The TAzureImageResponse holds an error object in this case that can be analyzed by the developer
    if (Result.Status = AzureSuccessed) or (Result.Status = AzureFailed) then
      Exit;
    // Check timeout - current documentation is not precise what to expect when the state is "inProgress"
    // but the result at this point should contain all relevant information
    {$IF CompilerVersion > 34}
    if TThread.GetTickCount64 - StartTime > Timeout then
      Exit;
    {$ELSE}
    if TThread.GetTickCount - StartTime > Timeout then
      Exit;
    {$ENDIF}
    Sleep(PollInterval);
    if Assigned(CancelCallback) then
      CancelCallback(Cancel);
  end;
end;

{ TImageAzureCreateParams }

function TImageAzureCreateParams.Caption(const Value: string): TImageAzureCreateParams;
begin
  Result := TImageAzureCreateParams(Add('caption', Value));
end;

function TImageAzureCreateParams.N(const Value: Integer): TImageAzureCreateParams;
begin
  Result := TImageAzureCreateParams(Add('n', Value));
end;

function TImageAzureCreateParams.ResponseFormat(const Value: string): TImageAzureCreateParams;
begin
  Result := TImageAzureCreateParams(Add('response_format', Value));
end;

function TImageAzureCreateParams.ResponseFormat(const Value: TImageResponseFormat): TImageAzureCreateParams;
begin
  Result := ResponseFormat(Value.ToString);
end;

function TImageAzureCreateParams.Resolution(const Value: string): TImageAzureCreateParams;
begin
  Result := TImageAzureCreateParams(Add('resolution', Value));
end;

function TImageAzureCreateParams.Resolution(const Value: TImageSize): TImageAzureCreateParams;
begin
  Result := Resolution(Value.ToString);
end;

function TImageAzureCreateParams.User(const Value: string): TImageAzureCreateParams;
begin
  Result := TImageAzureCreateParams(Add('user', Value));
end;

end.


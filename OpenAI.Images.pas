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

  TImageSize = (x256, x512, x1024);

  TImageSizeHelper = record helper for TImageSize
    function ToString: string;
  end;

  TImageCreateParams = class(TJSONParam)
    /// <summary>
    /// A text description of the desired image(s) for the openaid-environment. The maximum length is 1000 characters.
    /// </summary>
    function Prompt(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: TImageSize = TImageSize.x256): TImageCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageCreateParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageCreateParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
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
    function Resolution(const Value: TImageSize = TImageSize.x256): TImageAzureCreateParams; overload;
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
    function User(const Value: string): TImageAzureCreateParams;
  end;

  TImageEditParams = class(TMultipartFormData)
    /// <summary>
    /// The image to edit. Must be a valid PNG file, less than 4MB, and square.
    /// If mask is not provided, image must have transparency, which will be used as the mask.
    /// </summary>
    function Image(const FileName: string): TImageEditParams; overload;
    /// <summary>
    /// The image to edit. Must be a valid PNG file, less than 4MB, and square.
    /// If mask is not provided, image must have transparency, which will be used as the mask.
    /// </summary>
    function Image(const Stream: TStream; const FileName: string): TImageEditParams; overload;
    /// <summary>
    /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited.
    /// Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
    /// </summary>
    function Mask(const FileName: string): TImageEditParams; overload;
    /// <summary>
    /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited.
    /// Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
    /// </summary>
    function Mask(const Stream: TStream; const FileName: string): TImageEditParams; overload;
    /// <summary>
    /// A text description of the desired image(s). The maximum length is 1000 characters.
    /// </summary>
    function Prompt(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageEditParams;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: TImageSize = TImageSize.x256): TImageEditParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json.
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageEditParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TImageEditParams;
    constructor Create; reintroduce;
  end;

  TImageVariationParams = class(TMultipartFormData)
    /// <summary>
    /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
    /// </summary>
    function Image(const FileName: string): TImageVariationParams; overload;
    /// <summary>
    /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
    /// </summary>
    function Image(const Stream: TStream; const FileName: string): TImageVariationParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageVariationParams;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: TImageSize = TImageSize.x256): TImageVariationParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json.
    /// </summary>
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url): TImageVariationParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TImageVariationParams;
    constructor Create; reintroduce;
  end;

  TImageData = class
  private
    FUrl: string;
    FB64_json: string;
  public
    property Url: string read FUrl write FUrl;
    property B64Json: string read FB64_json write FB64_json;
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

function TImageCreateParams.N(const Value: Integer): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('n', Value));
end;

function TImageCreateParams.Prompt(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('prompt', Value));
end;

function TImageCreateParams.ResponseFormat(const Value: TImageResponseFormat): TImageCreateParams;
begin
  Result := ResponseFormat(Value.ToString);
end;

function TImageCreateParams.Size(const Value: TImageSize): TImageCreateParams;
begin
  Result := Size(Value.ToString);
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

function TImageEditParams.Image(const FileName: string): TImageEditParams;
begin
  AddFile('image', FileName);
  Result := Self;
end;

constructor TImageEditParams.Create;
begin
  inherited Create(true);
end;

function TImageEditParams.Image(const Stream: TStream; const FileName: string): TImageEditParams;
begin
  AddStream('image', Stream, FileName);
  Result := Self;
end;

function TImageEditParams.Mask(const Stream: TStream; const FileName: string): TImageEditParams;
begin
  AddStream('mask', Stream, FileName);
  Result := Self;
end;

function TImageEditParams.Mask(const FileName: string): TImageEditParams;
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

function TImageVariationParams.Image(const FileName: string): TImageVariationParams;
begin
  AddFile('image', FileName);
  Result := Self;
end;

constructor TImageVariationParams.Create;
begin
  inherited Create(true);
end;

function TImageVariationParams.Image(const Stream: TStream; const FileName: string): TImageVariationParams;
begin
  AddStream('image', Stream, FileName);
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

function TImageVariationParams.Size(const Value: TImageSize = TImageSize.x256): TImageVariationParams;
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
    TImageSize.x256:
      Result := '256x256';
    TImageSize.x512:
      Result := '512x512';
    TImageSize.x1024:
      Result := '1024x1024';
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
  StartTime := TThread.GetTickCount64;
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
    if TThread.GetTickCount64 - StartTime > Timeout then
      Exit;
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


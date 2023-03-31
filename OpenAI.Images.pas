unit OpenAI.Images;

interface

uses System.Classes, System.SysUtils, System.Net.Mime, OpenAI.API.Params, OpenAI.API;

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
    /// A text description of the desired image(s) for the azure-environment. The maximum length is 1000 characters.
    /// </summary>
    function Caption(const Value: string): TImageCreateParams; overload;
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
    function ResponseFormat(const Value: TImageResponseFormat = TImageResponseFormat.Url)
      : TImageCreateParams; overload;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageCreateParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TImageCreateParams;
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
    function Size(const Value: string = '1024x1024'): TImageEditParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json.
    /// </summary>
    function ResponseFormat(const Value: string = 'url'): TImageEditParams;
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
    function Size(const Value: string = '1024x1024'): TImageVariationParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json.
    /// </summary>
    function ResponseFormat(const Value: string = 'url'): TImageVariationParams;
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

  TAzureImageRequest = class
  private
    FID: string;
    FStatus: string;
  public
    property ID: string read FID write FID;
    property Status: string read FStatus write FStatus;
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
  public
    constructor Create;
    destructor Destroy; override;
    property Result: TAzureImageData read FResult write FResult;
    property ID: string read FID write FID;
    property Status: string read FStatus write FStatus;
  end;

  TImagesRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates an image given a prompt.
    /// </summary>
    function Create(ParamProc: TProc<TImageCreateParams>): TImageGenerations;
    function CreateAzure(ParamProc: TProc<TImageCreateParams>): TAzureImageResponse;
    /// <summary>
    /// Creates an edited or extended image given an original image and a prompt.
    /// </summary>
    function Edit(ParamProc: TProc<TImageEditParams>): TImageGenerations;
    /// <summary>
    /// Creates a variation of a given image.
    /// </summary>
    function Variation(ParamProc: TProc<TImageVariationParams>): TImageGenerations;
  end;

implementation

{ TImagesRoute }

function TImagesRoute.Create(ParamProc: TProc<TImageCreateParams>): TImageGenerations;
begin
  Result := API.Post<TImageGenerations, TImageCreateParams>('images/generations', ParamProc);
end;

function TImagesRoute.CreateAzure(ParamProc: TProc<TImageCreateParams>): TAzureImageResponse;
var
  ARequest: TAzureImageRequest;
begin
  // First place the task with POST
  ARequest := API.Post<TAzureImageRequest, TImageCreateParams>('text-to-image', ParamProc);

  // Repeat GET requesting the operations-endpoint until we have a "succeeded" response
  while true do
  begin
    Result := API.Get<TAzureImageResponse>('text-to-image/operations/' + ARequest.ID);
    if Result.FStatus = 'Succeeded' then
      exit;
    if Result.FStatus = 'Failed' then
      // We could parse the "error" object with fields "code" and "message" to handle errors if required
      exit;
    Sleep(1000);

    // Maybe add some kind of timeout?
  end;
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
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TImageCreateParams }

function TImageCreateParams.Caption(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('caption', Value));
end;

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

function TImageEditParams.Size(const Value: string): TImageEditParams;
begin
  AddField('size', Value);
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

function TImageVariationParams.Image(const Stream: TStream; const FileName: string)
  : TImageVariationParams;
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

function TImageVariationParams.Size(const Value: string): TImageVariationParams;
begin
  AddField('size', Value);
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

constructor TAzureImageResponse.Create;
begin
  FResult := TAzureImageData.Create;
end;

destructor TAzureImageResponse.Destroy;
begin
  FResult.Free;
  inherited;
end;

end.

unit OpenAI.Images;

interface

uses
  System.Classes, System.SysUtils, System.Net.Mime, OpenAI.API.Params,
  OpenAI.API;

type
  TImageCreateParams = class(TJSONParam)
    /// <summary>
    /// A text description of the desired image(s). The maximum length is 1000 characters.
    /// </summary>
    function Prompt(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: string = '1024x1024'): TImageCreateParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: string = 'url'): TImageCreateParams;
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
    if Assigned(Item) then
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

end.


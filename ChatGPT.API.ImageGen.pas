unit ChatGPT.API.ImageGen;

interface

uses
  ChatGPT.API.Params;

type
  TImageGenParams = class(TJSONParam)
    /// <summary>
    /// A text description of the desired image(s). The maximum length is 1000 characters.
    /// </summary>
    function Prompt(const Value: string): TImageGenParams; overload;
    /// <summary>
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    /// </summary>
    function Size(const Value: string = '1024x1024'): TImageGenParams; overload;
    /// <summary>
    /// The format in which the generated images are returned. Must be one of url or b64_json
    /// </summary>
    function ResponseFormat(const Value: string = 'url'): TImageGenParams;
    /// <summary>
    /// The number of images to generate. Must be between 1 and 10.
    /// </summary>
    function N(const Value: Integer = 1): TImageGenParams;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    function User(const Value: string): TImageGenParams;
    constructor Create; override;
  end;

  TGPTImageData = class
  private
    FUrl: string;
    FB64_json: string;
  public
    property Url: string read FUrl write FUrl;
    property B64Json: string read FB64_json write FB64_json;
  end;

  TGPTImageGen = class
  private
    FData: TArray<TGPTImageData>;
    FCreated: Int64;
  public
    property Data: TArray<TGPTImageData> read FData write FData;
    property Created: Int64 read FCreated write FCreated;
    destructor Destroy; override;
  end;

implementation

{ TGPTImageGen }

destructor TGPTImageGen.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TImageGenParams }

constructor TImageGenParams.Create;
begin
  inherited;
end;

function TImageGenParams.N(const Value: Integer): TImageGenParams;
begin
  Result := TImageGenParams(Add('n', Value));
end;

function TImageGenParams.Prompt(const Value: string): TImageGenParams;
begin
  Result := TImageGenParams(Add('prompt', Value));
end;

function TImageGenParams.Size(const Value: string): TImageGenParams;
begin
  Result := TImageGenParams(Add('size', Value));
end;

function TImageGenParams.ResponseFormat(const Value: string): TImageGenParams;
begin
  Result := TImageGenParams(Add('response_format', Value));
end;

function TImageGenParams.User(const Value: string): TImageGenParams;
begin
  Result := TImageGenParams(Add('user', Value));
end;

end.


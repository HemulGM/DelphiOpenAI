unit ChatGPT.API;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  ChatGPT.API.Completions, ChatGPT.API.Edits, ChatGPT.API.Error,
  ChatGPT.API.Params, ChatGPT.API.ImageGen;

type
  GPTException = class(Exception)
  private
    FCode: Int64;
    FParam: string;
    FType: string;
  public
    property &Type: string read FType write FType;
    property Code: Int64 read FCode write FCode;
    property Param: string read FParam write FParam;
    constructor Create(const Text, &Type: string; const Param: string = ''; Code: Int64 = -1); reintroduce;
  end;

  {$WARNINGS OFF}
  TGPTChatAPI = class(TComponent)
  private
    FHTTPClient: THTTPClient;
    FToken: string;
    procedure SetToken(const Value: string);
  protected
    procedure CheckAPI;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
    function Execute(const Path: string; Body: TJSONObject; Response: TStringStream): Integer; overload;
    function Execute<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
  public
    /// <summary>
    /// Given a prompt, the model will return one or more predicted completions,
    /// and can also return the probabilities of alternative tokens at each position
    /// </summary>
    function Completions(ParamProc: TProc<TCompletionParams>): TGPTCompletions;
    /// <summary>
    /// Given a prompt and an instruction, the model will return an edited version of the prompt.
    /// </summary>
    function Edits(ParamProc: TProc<TEditParams>): TGPTEdits;
    /// <summary>
    /// Given a prompt and/or an input image, the model will generate a new image.
    /// </summary>
    function ImageGeneration(ParamProc: TProc<TImageGenParams>): TGPTImageGen;
  end;
  {$WARNINGS ON}

const
  AIModelTextDavinci003 = 'text-davinci-003';
  AIModelDefault = AIModelTextDavinci003;

const
  URL_BASE = 'https://api.openai.com/v1';
  URL_QUERY_COMPLETIONS = 'completions';
  URL_QUERY_EDITS = 'edits';
  URL_QUERY_IMAGE_GEN = 'images/generations';

implementation

uses
  System.Net.URLClient, Rest.Json;

{ TGPTChatAPI }

constructor TGPTChatAPI.Create(AOwner: TComponent);
begin
  inherited;
  FHTTPClient := THTTPClient.Create;
  // Defaults
  FToken := '';
end;

constructor TGPTChatAPI.Create(AOwner: TComponent; const AToken: string);
begin
  Create(AOwner);
  Token := AToken;
end;

destructor TGPTChatAPI.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TGPTChatAPI.Execute(const Path: string; Body: TJSONObject; Response: TStringStream): Integer;
begin
  CheckAPI;
  var Headers: TNetHeaders := [
    TNetHeader.Create('Authorization', 'Bearer ' + FToken),
    TNetHeader.Create('Content-Type', 'application/json')];
  var Stream := TStringStream.Create;
  Stream.WriteString(Body.ToJSON);
  Stream.Position := 0;
  try
    Result := FHTTPClient.Post(URL_BASE + '/' + Path, Stream, Response, Headers).StatusCode;
  finally
    Stream.Free;
  end;
end;

function TGPTChatAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
begin
  case Code of
    200..299:
      Result := TJson.JsonToObject<T>(ResponseText);
  else
    var Error: TGPTErrorResponse;
    try
      Error := TJson.JsonToObject<TGPTErrorResponse>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) and Assigned(Error.Error) then
      raise GPTException.Create(Error.Error.Message, Error.Error.&Type, Error.Error.Param, Error.Error.Code)
    else
      raise GPTException.Create('Unknown error', '', '', Code);
  end;
end;

procedure TGPTChatAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise Exception.Create('Token is empty!');
end;

function TGPTChatAPI.Execute<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
begin
  var Response := TStringStream.Create;
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := Execute(Path, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TGPTChatAPI.ImageGeneration(ParamProc: TProc<TImageGenParams>): TGPTImageGen;
begin
  Result := Execute<TGPTImageGen, TImageGenParams>(URL_QUERY_IMAGE_GEN, ParamProc);
end;

function TGPTChatAPI.Edits(ParamProc: TProc<TEditParams>): TGPTEdits;
begin
  Result := Execute<TGPTEdits, TEditParams>(URL_QUERY_EDITS, ParamProc);
end;

function TGPTChatAPI.Completions(ParamProc: TProc<TCompletionParams>): TGPTCompletions;
begin
  Result := Execute<TGPTCompletions, TCompletionParams>(URL_QUERY_COMPLETIONS, ParamProc);
end;

procedure TGPTChatAPI.SetToken(const Value: string);
begin
  FToken := Value;
end;

{ GPTException }

constructor GPTException.Create(const Text, &Type, Param: string; Code: Int64);
begin
  inherited Create(Text);
  Self.&Type := &Type;
  Self.Code := Code;
  Self.Param := Param;
end;

end.


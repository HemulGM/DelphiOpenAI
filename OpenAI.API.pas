unit OpenAI.API;

interface

uses
  System.Classes, System.Net.HttpClient, System.Net.Mime, System.JSON,
  OpenAI.Params, System.SysUtils;

type
  OpenAIException = class(Exception)
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
  TOpenAIAPI = class(TComponent)
    const
      URL_BASE = 'https://api.openai.com/v1';
  private
    FHTTPClient: THTTPClient;
    FToken: string;
    FBaseUrl: string;
    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
  protected
    function Get(const Path: string; Response: TStringStream): Integer; overload;
    function Delete(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TMultipartFormData; Response: TStringStream): Integer; overload;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
    procedure CheckAPI;
  public
    function Get<TResult: class, constructor>(const Path: string): TResult; overload;
    procedure GetFile(const Path: string; Response: TStream); overload;
    function Delete<TResult: class, constructor>(const Path: string): TResult; overload;
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
  end;
  {$WARNINGS ON}

  TOpenAIAPIRoute = class
  private
    FAPI: TOpenAIAPI;
    procedure SetAPI(const Value: TOpenAIAPI);
  public
    property API: TOpenAIAPI read FAPI write SetAPI;
    constructor CreateRoute(AAPI: TOpenAIAPI); reintroduce;
  end;

implementation

uses
  System.Net.URLClient, OpenAI.Errors, REST.Json;

constructor TOpenAIAPI.Create(AOwner: TComponent);
begin
  inherited;
  FHTTPClient := THTTPClient.Create;
  // Defaults
  FToken := '';
  FBaseUrl := URL_BASE;
end;

constructor TOpenAIAPI.Create(AOwner: TComponent; const AToken: string);
begin
  Create(AOwner);
  Token := AToken;
end;

destructor TOpenAIAPI.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TOpenAIAPI.Post(const Path: string; Body: TJSONObject; Response: TStringStream): Integer;
begin
  CheckAPI;
  var Headers: TNetHeaders := [
    TNetHeader.Create('Authorization', 'Bearer ' + FToken),
    TNetHeader.Create('Content-Type', 'application/json')];
  var Stream := TStringStream.Create;
  Stream.WriteString(Body.ToJSON);
  Stream.Position := 0;
  try
    Result := FHTTPClient.Post(FBaseUrl + '/' + Path, Stream, Response, Headers).StatusCode;
  finally
    Stream.Free;
  end;
end;

function TOpenAIAPI.Get(const Path: string; Response: TStringStream): Integer;
begin
  CheckAPI;
  var Headers: TNetHeaders := [TNetHeader.Create('Authorization', 'Bearer ' + FToken)];
  Result := FHTTPClient.Get(FBaseUrl + '/' + Path, Response, Headers).StatusCode;
end;

function TOpenAIAPI.Post(const Path: string; Body: TMultipartFormData; Response: TStringStream): Integer;
begin
  CheckAPI;
  var Headers: TNetHeaders := [TNetHeader.Create('Authorization', 'Bearer ' + FToken)];
  Result := FHTTPClient.Post(FBaseUrl + '/' + Path, Body, Response, Headers).StatusCode;
end;

function TOpenAIAPI.Post<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
begin
  var Response := TStringStream.Create;
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := Post(Path, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TOpenAIAPI.Delete(const Path: string; Response: TStringStream): Integer;
begin
  CheckAPI;
  var Headers: TNetHeaders := [TNetHeader.Create('Authorization', 'Bearer ' + FToken)];
  Result := FHTTPClient.Delete(FBaseUrl + '/' + Path, Response, Headers).StatusCode;
end;

function TOpenAIAPI.Delete<TResult>(const Path: string): TResult;
begin
  var Response := TStringStream.Create;
  try
    var Code := Delete(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TOpenAIAPI.PostForm<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
begin
  var Response := TStringStream.Create;
  var Params := TMultipartFormData.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := Post(Path, Params, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TOpenAIAPI.Get<TResult>(const Path: string): TResult;
begin
  var Response := TStringStream.Create;
  try
    var Code := Get(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

procedure TOpenAIAPI.GetFile(const Path: string; Response: TStream);
begin
  CheckAPI;
  var Headers: TNetHeaders := [TNetHeader.Create('Authorization', 'Bearer ' + FToken)];
  var Code := FHTTPClient.Get(FBaseUrl + '/' + Path, Response, Headers).StatusCode;
  case Code of
    200..299: {success}
      ;
  else
    raise OpenAIException.Create('Error downloading', '', Path, Code);
  end;
end;

procedure TOpenAIAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise Exception.Create('Token is empty!');
  if FBaseUrl.IsEmpty then
    raise Exception.Create('Base url is empty!');
end;

function TOpenAIAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
begin
  case Code of
    200..299:
      {$WARNINGS OFF}
      Result := TJson.JsonToObject<T>(UTF8ToString(ResponseText));
      {$WARNINGS ON}
  else
    var Error: TGPTErrorResponse;
    try
      {$WARNINGS OFF}
      Error := TJson.JsonToObject<TGPTErrorResponse>(UTF8ToString(ResponseText));
      {$WARNINGS ON}
    except
      Error := nil;
    end;
    if Assigned(Error) and Assigned(Error.Error) then
      raise OpenAIException.Create(Error.Error.Message, Error.Error.&Type, Error.Error.Param, Error.Error.Code)
    else
      raise OpenAIException.Create('Unknown error', '', '', Code);
  end;
  if not Assigned(Result) then
    raise OpenAIException.Create('Empty response', '', '', Code);
end;

procedure TOpenAIAPI.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TOpenAIAPI.SetToken(const Value: string);
begin
  FToken := Value;
end;

{ OpenAIException }

constructor OpenAIException.Create(const Text, &Type, Param: string; Code: Int64);
begin
  inherited Create(Text);
  Self.&Type := &Type;
  Self.Code := Code;
  Self.Param := Param;
end;

{ TOpenAIAPIRoute }

constructor TOpenAIAPIRoute.CreateRoute(AAPI: TOpenAIAPI);
begin
  inherited Create;
  FAPI := AAPI;
end;

procedure TOpenAIAPIRoute.SetAPI(const Value: TOpenAIAPI);
begin
  FAPI := Value;
end;

end.


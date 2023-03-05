unit OpenAI.API;

interface

uses
  System.Classes, System.Net.HttpClient, System.Net.URLClient, System.Net.Mime,
  System.JSON, OpenAI.Errors, OpenAI.API.Params, System.SysUtils;

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

  OpenAIExceptionAPI = class(Exception);

  /// <summary>
  /// An InvalidRequestError indicates that your request was malformed or
  // missing some required parameters, such as a token or an input.
  // This could be due to a typo, a formatting error, or a logic error in your code.
  /// </summary>
  OpenAIExceptionInvalidRequestError = class(OpenAIException);

  /// <summary>
  /// A `RateLimitError` indicates that you have hit your assigned rate limit.
  /// This means that you have sent too many tokens or requests in a given period of time,
  /// and our services have temporarily blocked you from sending more.
  /// </summary>
  OpenAIExceptionRateLimitError = class(OpenAIException);

  /// <summary>
  /// An `AuthenticationError` indicates that your API key or token was invalid,
  /// expired, or revoked. This could be due to a typo, a formatting error, or a security breach.
  /// </summary>
  OpenAIExceptionAuthenticationError = class(OpenAIException);

  /// <summary>
  /// This error message indicates that your account is not part of an organization
  /// </summary>
  OpenAIExceptionPermissionError = class(OpenAIException);

  /// <summary>
  /// This error message indicates that our servers are experiencing high
  /// traffic and are unable to process your request at the moment
  /// </summary>
  OpenAIExceptionTryAgain = class(OpenAIException);

  OpenAIExceptionInvalidResponse = class(OpenAIException);

  {$WARNINGS OFF}
  TOpenAIAPI = class
    const
      URL_BASE = 'https://api.openai.com/v1';
  private
    FHTTPClient: THTTPClient;
    FToken: string;
    FBaseUrl: string;
    FOrganization: string;
    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure SetOrganization(const Value: string);
    procedure ParseAndRaiseError(Error: TError; Code: Int64);
    procedure ParseError(const Code: Int64; const ResponseText: string);
  protected
    function GetHeaders: TNetHeaders;
    function Get(const Path: string; Response: TStringStream): Integer; overload;
    function Delete(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TMultipartFormData; Response: TStringStream): Integer; overload;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
    procedure CheckAPI;
  public
    function Get<TResult: class, constructor>(const Path: string): TResult; overload;
    procedure GetFile(const Path: string; Response: TStream); overload;
    function Delete<TResult: class, constructor>(const Path: string): TResult; overload;
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function Post<TResult: class, constructor>(const Path: string): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
  public
    constructor Create; overload;
    constructor Create(const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
    property Organization: string read FOrganization write SetOrganization;
    property Client: THTTPClient read FHTTPClient;
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
  REST.Json;

constructor TOpenAIAPI.Create;
begin
  inherited;
  FHTTPClient := THTTPClient.Create;
  // Defaults
  FToken := '';
  FBaseUrl := URL_BASE;
end;

constructor TOpenAIAPI.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor TOpenAIAPI.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TOpenAIAPI.Post(const Path: string; Body: TJSONObject; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders + [TNetHeader.Create('Content-Type', 'application/json')];
  Stream := TStringStream.Create;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHTTPClient.Post(FBaseUrl + '/' + Path, Stream, Response, Headers).StatusCode;
  finally
    Stream.Free;
  end;
end;

function TOpenAIAPI.Get(const Path: string; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
begin
  CheckAPI;
  Headers := GetHeaders;
  Result := FHTTPClient.Get(FBaseUrl + '/' + Path, Response, Headers).StatusCode;
end;

function TOpenAIAPI.Post(const Path: string; Body: TMultipartFormData; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
begin
  CheckAPI;
  Headers := GetHeaders;
  Result := FHTTPClient.Post(FBaseUrl + '/' + Path, Body, Response, Headers).StatusCode;
end;

function TOpenAIAPI.Post(const Path: string; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders;
  Stream := nil;
  try
    Result := FHTTPClient.Post(FBaseUrl + '/' + Path, Stream, Response, Headers).StatusCode;
  finally
    //Stream.Free;
  end;
end;

function TOpenAIAPI.Post<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('',TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TOpenAIAPI.Post<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('',TEncoding.UTF8);
  try
    Code := Post(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TOpenAIAPI.Delete(const Path: string; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
begin
  CheckAPI;
  Headers := GetHeaders;
  Result := FHTTPClient.Delete(FBaseUrl + '/' + Path, Response, Headers).StatusCode;
end;

function TOpenAIAPI.Delete<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('',TEncoding.UTF8);
  try
    Code := Delete(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TOpenAIAPI.PostForm<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('',TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TOpenAIAPI.Get<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('',TEncoding.UTF8);
  try
    Code := Get(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

procedure TOpenAIAPI.GetFile(const Path: string; Response: TStream);
var
  Headers: TNetHeaders;
  Code: Integer;
  Strings: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders;
  Code := FHTTPClient.Get(FBaseUrl + '/' + Path, Response, Headers).StatusCode;
  case Code of
    200..299:
      ; {success}
  else
    Strings := TStringStream.Create;
    try
      Response.Position := 0;
      Strings.LoadFromStream(Response);
      ParseError(Code, Strings.DataString);
    finally
      Strings.Free;
    end;
  end;
end;

function TOpenAIAPI.GetHeaders: TNetHeaders;
begin
  Result := [TNetHeader.Create('Authorization', 'Bearer ' + FToken)];
  if not FOrganization.IsEmpty then
    Result := Result + [TNetHeader.Create('OpenAI-Organization', FOrganization)];
end;

procedure TOpenAIAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise OpenAIExceptionAPI.Create('Token is empty!');
  if FBaseUrl.IsEmpty then
    raise OpenAIExceptionAPI.Create('Base url is empty!');
end;

procedure TOpenAIAPI.ParseAndRaiseError(Error: TError; Code: Int64);
begin
  case Code of
    429:
      raise OpenAIExceptionRateLimitError.Create(Error.Message, Error.&Type, Error.Param, Error.Code);
    400, 404, 415:
      raise OpenAIExceptionInvalidRequestError.Create(Error.Message, Error.&Type, Error.Param, Error.Code);
    401:
      raise OpenAIExceptionAuthenticationError.Create(Error.Message, Error.&Type, Error.Param, Error.Code);
    403:
      raise OpenAIExceptionPermissionError.Create(Error.Message, Error.&Type, Error.Param, Error.Code);
    409:
      raise OpenAIExceptionTryAgain.Create(Error.Message, Error.&Type, Error.Param, Error.Code);
  else
    raise OpenAIException.Create(Error.Message, Error.&Type, Error.Param, Error.Code);
  end;
end;

procedure TOpenAIAPI.ParseError(const Code: Int64; const ResponseText: string);
var
  Error: TErrorResponse;
begin
  Error := nil;
  try
    try
      {$IFDEF ANDROID}
      Error := TJson.JsonToObject<TErrorResponse>(ResponseText);
      {$ELSE}
      Error := TJson.JsonToObject<TErrorResponse>(UTF8ToString(RawByteString(ResponseText)));
      {$ENDIF}
    except
      Error := nil;
    end;
    if Assigned(Error) and Assigned(Error.Error) then
      ParseAndRaiseError(Error.Error, Code)
    else
      raise OpenAIException.Create('Unknown error', '', '', Code);
  finally
    if Assigned(Error) then
      Error.Free;
  end;
end;

function TOpenAIAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
begin
  case Code of
    200..299:
      try
        {$IFDEF ANDROID}
        Result := TJson.JsonToObject<T>(ResponseText);
        {$ELSE}
        //Result := TJson.JsonToObject<T>(UTF8ToString(RawByteString(ResponseText)));
        Result := TJson.JsonToObject<T>(ResponseText);
        {$ENDIF}
      except
        Result := nil;
      end;
  else
    ParseError(Code, ResponseText);
  end;
  if not Assigned(Result) then
    raise OpenAIExceptionInvalidResponse.Create('Empty or invalid response', '', '', Code);
end;

procedure TOpenAIAPI.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TOpenAIAPI.SetOrganization(const Value: string);
begin
  FOrganization := Value;
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


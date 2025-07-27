﻿unit OpenAI.API;

interface

uses
  System.Classes, System.SysUtils, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON, System.Generics.Collections, OpenAI.Errors,
  OpenAI.API.Params;

type
  TOpenAIAPI = class;

  {$IF RTLVersion < 35.0}
  TURLClientHelper = class helper for TURLClient
  public
    const
      DefaultConnectionTimeout = 60000;
      DefaultSendTimeout = 60000;
      DefaultResponseTimeout = 60000;
  end;
  {$ENDIF}

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

  OpenAIPrepareException = class(OpenAIException);

  IAPIPrepare = interface
    ['{10B51102-8D50-40F5-AD6D-E44D9B22A56F}']
    procedure PrepareQuery(API: TOpenAIAPI);
  end;

  {$WARNINGS OFF}
  TOpenAIAPI = class
  public
    const
      URL_BASE = 'https://api.openai.com/v1';
  private
    FToken: string;
    FBaseUrl: string;
    FOrganization: string;

    FIsAzure: Boolean;
    FAzureApiVersion: string;
    FAzureDeployment: string;
    FCustomHeaders: TNetHeaders;
    FProxySettings: TProxySettings;
    FConnectionTimeout: Integer;
    FSendTimeout: Integer;
    FResponseTimeout: Integer;
    FAssistantsVersion: string;
    FDisableBearerPrefix: Boolean;
    FPrepare: IAPIPrepare;

    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure SetOrganization(const Value: string);
    procedure ParseAndRaiseError(Error: TError; Code: Int64);
    procedure ParseError(const Code: Int64; const ResponseText: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);
    procedure SetProxySettings(const Value: TProxySettings);
    procedure SetConnectionTimeout(const Value: Integer);
    procedure SetResponseTimeout(const Value: Integer);
    procedure SetSendTimeout(const Value: Integer);
  protected
    function GetHeaders: TNetHeaders; virtual;
    function GetRequestURL(const Path: string): string;
    function Get(const Path: string; Response: TStream): Integer; overload;
    function Delete(const Path: string; Response: TStream): Integer; overload;
    function Post(const Path: string; Response: TStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; Response: TStream; OnReceiveData: TReceiveDataCallback = nil): Integer; overload;
    function Post(const Path: string; Body: TMultipartFormData; Response: TStream): Integer; overload;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
    procedure CheckAPI;
  public
    function GetClient: THTTPClient; virtual;
    function Get<TResult: class, constructor>(const Path: string): TResult; overload;
    function Get<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    procedure GetFile(const Path: string; Response: TStream); overload;
    function Delete<TResult: class, constructor>(const Path: string): TResult; overload;
    function Post<TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>; Response: TStream; Event: TReceiveDataCallback = nil): Boolean; overload;
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
    property ProxySettings: TProxySettings read FProxySettings write SetProxySettings;
    /// <summary> Property to set/get the ConnectionTimeout. Value is in milliseconds.
    ///  -1 - Infinite timeout. 0 - platform specific timeout. Supported by Windows, Linux, Android platforms. </summary>
    property ConnectionTimeout: Integer read FConnectionTimeout write SetConnectionTimeout;
    /// <summary> Property to set/get the SendTimeout. Value is in milliseconds.
    ///  -1 - Infinite timeout. 0 - platform specific timeout. Supported by Windows, macOS platforms. </summary>
    property SendTimeout: Integer read FSendTimeout write SetSendTimeout;
    /// <summary> Property to set/get the ResponseTimeout. Value is in milliseconds.
    ///  -1 - Infinite timeout. 0 - platform specific timeout. Supported by all platforms. </summary>
    property ResponseTimeout: Integer read FResponseTimeout write SetResponseTimeout;
    property IsAzure: Boolean read FIsAzure write FIsAzure;
    property DisableBearerPrefix: Boolean read FDisableBearerPrefix write FDisableBearerPrefix;
    property AzureApiVersion: string read FAzureApiVersion write FAzureApiVersion;
    property AzureDeployment: string read FAzureDeployment write FAzureDeployment;
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;
    /// <summary>
    /// Example: v1, v2, ...
    /// </summary>
    property AssistantsVersion: string read FAssistantsVersion write FAssistantsVersion;
    property Prepare: IAPIPrepare read FPrepare write FPrepare;
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
  REST.Json, System.NetConsts, OpenAI.Utils.JSON.Cleaner;

constructor TOpenAIAPI.Create;
begin
  inherited;
  // Defaults
  FConnectionTimeout := TURLClient.DefaultConnectionTimeout;
  FSendTimeout := TURLClient.DefaultSendTimeout;
  FResponseTimeout := TURLClient.DefaultResponseTimeout;
  FToken := '';
  FBaseUrl := URL_BASE;
  FIsAzure := False;
  FDisableBearerPrefix := False;
  FAzureApiVersion := '';
  FAzureDeployment := '';
end;

constructor TOpenAIAPI.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor TOpenAIAPI.Destroy;
begin
  inherited;
end;

function TOpenAIAPI.Post(const Path: string; Body: TJSONObject; Response: TStream; OnReceiveData: TReceiveDataCallback): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;

  try
    Headers := GetHeaders + [TNetHeader.Create('Content-Type', 'application/json')];
    Stream := TStringStream.Create;
    Client.ReceiveDataCallBack := OnReceiveData;
    try
      Stream.WriteString(Body.ToJSON);
      Stream.Position := 0;
      Result := Client.Post(GetRequestURL(Path), Stream, Response, Headers).StatusCode;
    finally
      Client.OnReceiveData := nil;
      Stream.Free;
    end;
  finally
    Client.Free;
  end;
end;

function TOpenAIAPI.Get(const Path: string; Response: TStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Get(GetRequestURL(Path), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function TOpenAIAPI.Post(const Path: string; Body: TMultipartFormData; Response: TStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Post(GetRequestURL(Path), Body, Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function TOpenAIAPI.Post(const Path: string; Response: TStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Post(GetRequestURL(Path), TStream(nil), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function TOpenAIAPI.Post<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
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

function TOpenAIAPI.Post<TParams>(const Path: string; ParamProc: TProc<TParams>; Response: TStream; Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
  Code: Integer;
  Strings: TStringStream;
begin
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params.JSON, Response, Event);
    case Code of
      200..299:
        Result := True;
    else
      Result := False;
      if Response is TStringStream then
        ParseError(Code, TStringStream(Response).DataString)
      else
      begin
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
  finally
    Params.Free;
  end;
end;

function TOpenAIAPI.Post<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Post(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TOpenAIAPI.Delete(const Path: string; Response: TStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Delete(GetRequestURL(Path), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function TOpenAIAPI.Delete<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
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
  Response := TStringStream.Create('', TEncoding.UTF8);
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

function TOpenAIAPI.Get<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Pair: TPair<string, string>;
  Code: Integer;
  Pairs: TArray<string>;
  QPath: string;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Pairs := [];
    for Pair in Params.ToStringPairs do
      Pairs := Pairs + [Pair.Key + '=' + Pair.Value];
    QPath := Path;
    if Length(Pairs) > 0 then
      QPath := QPath + '?' + string.Join('&', Pairs);
    Code := Get(QPath, Response);
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
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TOpenAIAPI.GetClient: THTTPClient;
begin
  Result := THTTPClient.Create;
  Result.ProxySettings := FProxySettings;
  Result.ConnectionTimeout := FConnectionTimeout;
  Result.ResponseTimeout := FResponseTimeout;
  {$IF RTLVersion >= 35.0}
  Result.SendTimeout := FSendTimeout;
  {$ENDIF}
  Result.AcceptCharSet := 'utf-8';
end;

procedure TOpenAIAPI.GetFile(const Path: string; Response: TStream);
var
  Code: Integer;
  Strings: TStringStream;
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Code := Client.Get(GetRequestURL(Path), Response, GetHeaders).StatusCode;
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
  finally
    Client.Free;
  end;
end;

function TOpenAIAPI.GetHeaders: TNetHeaders;
begin
  // Additional headers are not required when using azure
  if IsAzure then
    Exit;

  if DisableBearerPrefix then
    Result := [TNetHeader.Create('Authorization', FToken)] + FCustomHeaders
  else
    Result := [TNetHeader.Create('Authorization', 'Bearer ' + FToken)] + FCustomHeaders;
  if not FOrganization.IsEmpty then
    Result := Result + [TNetHeader.Create('OpenAI-Organization', FOrganization)];
  if not FAssistantsVersion.IsEmpty then
    Result := Result + [TNetHeader.Create('OpenAI-Beta', 'assistants=' + FAssistantsVersion)];
end;

function TOpenAIAPI.GetRequestURL(const Path: string): string;
begin
  Result := FBaseURL + '/';
  if IsAzure then
    Result := Result + AzureDeployment + '/';
  Result := Result + Path;

  // API-Key and API-Version have to be included in the request not header when using azure
  if IsAzure then
    Result := Result + Format('?api-version=%s&api-key=%s', [AzureApiVersion, Token]);
end;

procedure TOpenAIAPI.CheckAPI;
begin
  if Assigned(FPrepare) then
    FPrepare.PrepareQuery(Self);
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
      Error := TJson.JsonToObject<TErrorResponse>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) and Assigned(Error.Error) then
      ParseAndRaiseError(Error.Error, Code)
    else
      raise OpenAIException.Create('Unknown error. Code: ' + Code.ToString, '', '', Code);
  finally
    Error.Free;
  end;
end;

function TOpenAIAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
var
  JO: TJSONObject;
  {$IF CompilerVersion <= 35}
  ClearedJSON: string; // fix for Delphi < 11 versions
  {$ENDIF}
begin
  Result := nil;
  {$IF CompilerVersion <= 35}
  ClearedJSON := TJSONCleaner<T>.New.CleanJSON(ResponseText);
  {$ENDIF}
  case Code of
    200..299:
      try
        {$IF CompilerVersion <= 35}
        Result := TJson.JsonToObject<T>(ClearedJSON);
        {$ELSE}
        Result := TJson.JsonToObject<T>(ResponseText);
        {$ENDIF}
      except
        try
          // try parse as part of object with text field (example, vtt)
          {$IF CompilerVersion <= 35}
          JO := TJSONObject.Create(TJSONPair.Create('text', ClearedJSON));
          {$ELSE}
          JO := TJSONObject.Create(TJSONPair.Create('text', ResponseText));
          {$ENDIF}
          try
            Result := TJson.JsonToObject<T>(JO);
          finally
            JO.Free;
          end;
        except
          Result := nil;
        end;
      end;
  else
    {$IF CompilerVersion <= 35}
    ParseError(Code, ClearedJSON);
    {$ELSE}
    ParseError(Code, ResponseText);
    {$ENDIF}
  end;
  if not Assigned(Result) then
    raise OpenAIExceptionInvalidResponse.Create('Empty or invalid response', '', '', Code);
end;

procedure TOpenAIAPI.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TOpenAIAPI.SetConnectionTimeout(const Value: Integer);
begin
  FConnectionTimeout := Value;
end;

procedure TOpenAIAPI.SetCustomHeaders(const Value: TNetHeaders);
begin
  FCustomHeaders := Value;
end;

procedure TOpenAIAPI.SetOrganization(const Value: string);
begin
  FOrganization := Value;
end;

procedure TOpenAIAPI.SetProxySettings(const Value: TProxySettings);
begin
  FProxySettings := Value;
end;

procedure TOpenAIAPI.SetResponseTimeout(const Value: Integer);
begin
  FResponseTimeout := Value;
end;

procedure TOpenAIAPI.SetSendTimeout(const Value: Integer);
begin
  FSendTimeout := Value;
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


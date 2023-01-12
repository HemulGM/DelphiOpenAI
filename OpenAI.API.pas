unit OpenAI.API;

interface

uses
  System.Classes, System.Net.HttpClient, System.JSON, OpenAI.Params,
  System.SysUtils;

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
    procedure SetToken(const Value: string);
  public
    procedure CheckAPI;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
    function Execute(const Path: string; Body: TJSONObject; Response: TStringStream): Integer; overload;
    function Execute<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function Execute<TResult: class, constructor>(const Path: string): TResult; overload;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
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

function TOpenAIAPI.Execute(const Path: string; Body: TJSONObject; Response: TStringStream): Integer;
begin
  CheckAPI;
  var Headers: TNetHeaders := [
    TNetHeader.Create('Authorization', 'Bearer ' + FToken),
    TNetHeader.Create('Content-Type', 'application/json')];
  if Assigned(Body) then
  begin
    var Stream := TStringStream.Create;
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    try
      Result := FHTTPClient.Post(URL_BASE + '/' + Path, Stream, Response, Headers).StatusCode;
    finally
      Stream.Free;
    end;
  end
  else
    Result := FHTTPClient.Get(URL_BASE + '/' + Path, Response, Headers).StatusCode;
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

procedure TOpenAIAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise Exception.Create('Token is empty!');
end;

function TOpenAIAPI.Execute<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
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

function TOpenAIAPI.Execute<TResult>(const Path: string): TResult;
begin
  var Response := TStringStream.Create;
  try
    var Code := Execute(Path, nil, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
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


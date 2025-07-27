unit OpenAI.GigaChat;

interface

uses
  System.SysUtils, System.Classes, OpenAI.API;

type
  TApiPrepareGigaChat = class(TInterfacedObject, IAPIPrepare)
    const
      SBER_GIGACHAT_OAUTH = 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth';
      SBER_GIGACHAT_OAUTH_SCOPE = 'GIGACHAT_API_PERS';
  private
    FClientID: string;
    FAuthorizationKey: string;
    FAccessToken: string;
    FExpiresAt: TDateTime;
    function IsValidToken: Boolean;
    procedure UpdateToken(API: TOpenAIAPI);
  public
    procedure PrepareQuery(API: TOpenAIAPI);
    constructor Create(const ClientID, AuthorizationKey: string); reintroduce;
  end;

implementation

uses
  System.Net.URLClient, System.JSON, System.DateUtils, System.NetConsts,
  System.Net.HttpClient;

{ TApiPrepareGigaChat }

constructor TApiPrepareGigaChat.Create(const ClientID, AuthorizationKey: string);
begin
  inherited Create;
  FClientID := ClientID;
  FAuthorizationKey := AuthorizationKey;
end;

function TApiPrepareGigaChat.IsValidToken: Boolean;
begin
  Result := (not FAccessToken.IsEmpty) and (FExpiresAt > Now);
end;

procedure TApiPrepareGigaChat.PrepareQuery(API: TOpenAIAPI);
begin
  if not IsValidToken then
    UpdateToken(API);
  API.Token := FAccessToken;
end;

procedure TApiPrepareGigaChat.UpdateToken(API: TOpenAIAPI);
begin
  var Client := API.GetClient;
  try
    Client.Accept := 'application/json';
    Client.CustomHeaders['RqUID'] := FClientID;
    Client.CustomHeaders['Authorization'] := 'Basic ' + FAuthorizationKey;
    var Content := TStringList.Create;
    try
      Content.AddPair('scope', SBER_GIGACHAT_OAUTH_SCOPE);
      var Response := Client.Post(SBER_GIGACHAT_OAUTH, Content);
      if Response.StatusCode <> 200 then
        raise OpenAIPrepareException.Create(Response.StatusText, '', '', Response.StatusCode);
      var JSON := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        FAccessToken := JSON.GetValue<string>('access_token', '');
        FExpiresAt := UnixToDateTime(JSON.GetValue<Int64>('expires_at', 0) div MSecsPerSec, False);
        if not IsValidToken then
          raise OpenAIPrepareException.Create('Token receipt error', '', '', Response.StatusCode);
      finally
        JSON.Free;
      end;
    finally
      Content.Free;
    end;
  finally
    Client.Free;
  end;
end;

end.


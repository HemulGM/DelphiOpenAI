unit OpenAI.Component.ChatHistory;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  System.Threading, OpenAI, OpenAI.Chat, OpenAI.Utils.ObjectHolder,
  OpenAI.Utils.ChatHistory;

type
  TChat = OpenAI.Chat.TChat;

  TChatMessageBuild = OpenAI.Chat.TChatMessageBuild;

  TOpenAIChatHistoryCustom = class(TComponent)
  private
    function GetAutoTrim: Boolean;
    function GetMaxTokensForQuery: Int64;
    function GetMaxTokensOfModel: Int64;
    procedure SetAutoTrim(const Value: Boolean);
    procedure SetMaxTokensForQuery(const Value: Int64);
    procedure SetMaxTokensOfModel(const Value: Int64);
  protected
    FItems: TChatHistory;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items: TChatHistory read FItems;
    property AutoTrim: Boolean read GetAutoTrim write SetAutoTrim;
    property MaxTokensForQuery: Int64 read GetMaxTokensForQuery write SetMaxTokensForQuery;
    property MaxTokensOfModel: Int64 read GetMaxTokensOfModel write SetMaxTokensOfModel;
  end;

  TOpenAIChatHistory = class(TOpenAIChatHistoryCustom)
  published
    property AutoTrim;
    property MaxTokensForQuery;
    property MaxTokensOfModel;
  end;

implementation

{ TOpenAIChatHistoryCustom }

constructor TOpenAIChatHistoryCustom.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TChatHistory.Create;
end;

destructor TOpenAIChatHistoryCustom.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TOpenAIChatHistoryCustom.GetAutoTrim: Boolean;
begin
  Result := FItems.AutoTrim;
end;

function TOpenAIChatHistoryCustom.GetMaxTokensForQuery: Int64;
begin
  Result := FItems.MaxTokensForQuery;
end;

function TOpenAIChatHistoryCustom.GetMaxTokensOfModel: Int64;
begin
  Result := FItems.MaxTokensOfModel;
end;

procedure TOpenAIChatHistoryCustom.SetAutoTrim(const Value: Boolean);
begin
  FItems.AutoTrim := Value;
end;

procedure TOpenAIChatHistoryCustom.SetMaxTokensForQuery(const Value: Int64);
begin
  FItems.MaxTokensForQuery := Value;
end;

procedure TOpenAIChatHistoryCustom.SetMaxTokensOfModel(const Value: Int64);
begin
  FItems.MaxTokensOfModel := Value;
end;

end.


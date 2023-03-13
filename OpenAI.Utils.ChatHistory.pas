unit OpenAI.Utils.ChatHistory;

interface

uses
  System.SysUtils, System.Generics.Collections, OpenAI.Chat;

type
  TOnCalcTokens = procedure(Sender: TObject; const Content: string; var TokenCount: Int64) of object;

  /// <summary>
  /// This class is used to store chat history.
  /// It can automatically delete previous messages if the total message size exceeds the specified number of tokens.
  /// <br>
  /// Use the ToArray method to pass the history to the Chat.Create request parameters
  /// </summary>
  TChatHistory = class(TList<TChatMessageBuild>)
  private
    FAutoTrim: Boolean;
    FMaxTokensForQuery: Int64;
    FMaxTokensOfModel: Int64;
    FOnCalcContentTokens: TOnCalcTokens;
    procedure SetAutoTrim(const Value: Boolean);
    procedure SetMaxTokensForQuery(const Value: Int64);
    procedure SetMaxTokensOfModel(const Value: Int64);
    procedure SetOnCalcContentTokens(const Value: TOnCalcTokens);
  protected
    procedure Notify(const Item: TChatMessageBuild; Action: TCollectionNotification); override;
  public
    procedure New(Role: TMessageRole; Content: string);
    function TextLength: Int64;
    property AutoTrim: Boolean read FAutoTrim write SetAutoTrim;
    property MaxTokensForQuery: Int64 read FMaxTokensForQuery write SetMaxTokensForQuery;
    property MaxTokensOfModel: Int64 read FMaxTokensOfModel write SetMaxTokensOfModel;
    property OnCalcContentTokens: TOnCalcTokens read FOnCalcContentTokens write SetOnCalcContentTokens;
    constructor Create;
  end;

const
  DEFULT_MAX_TOKENS = 1024;
  DEFULT_MODEL_TOKENS_LIMIT = 4096;

implementation

{ TChatHistory }

constructor TChatHistory.Create;
begin
  inherited;
  FMaxTokensForQuery := DEFULT_MAX_TOKENS;
  FMaxTokensOfModel := DEFULT_MODEL_TOKENS_LIMIT;
end;

procedure TChatHistory.New(Role: TMessageRole; Content: string);
begin
  Add(TChatMessageBuild.Create(Role, Content));
end;

procedure TChatHistory.Notify(const Item: TChatMessageBuild; Action: TCollectionNotification);
begin
  inherited;
  if FAutoTrim and (Action = TCollectionNotification.cnAdded) then
  begin
    while TextLength + FMaxTokensForQuery > FMaxTokensOfModel do
      Delete(0);
  end;
end;

procedure TChatHistory.SetAutoTrim(const Value: Boolean);
begin
  FAutoTrim := Value;
end;

procedure TChatHistory.SetMaxTokensForQuery(const Value: Int64);
begin
  FMaxTokensForQuery := Value;
end;

procedure TChatHistory.SetMaxTokensOfModel(const Value: Int64);
begin
  FMaxTokensOfModel := Value;
end;

procedure TChatHistory.SetOnCalcContentTokens(const Value: TOnCalcTokens);
begin
  FOnCalcContentTokens := Value;
end;

function TChatHistory.TextLength: Int64;
var
  ItemTokenCount: Int64;
  Item: TChatMessageBuild;
begin
  Result := 0;
  if Assigned(FOnCalcContentTokens) then
    for Item in Self do
    begin
      ItemTokenCount := 0;
      FOnCalcContentTokens(Self, Item.Content, ItemTokenCount);
      Inc(Result, ItemTokenCount);
    end
  else
  begin
    for Item in Self do
      Inc(Result, Item.Content.Length);
  end;
end;

end.


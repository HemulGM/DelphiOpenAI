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
    procedure New(Role: TMessageRole; Content, Tag: string);
    procedure NewFunc(const FuncName, FuncResult, Tag: string);
    procedure NewAsistantFunc(const FuncName, Args, Tag: string);
    procedure SetContentByTag(const Tag, Text: string);
    function TextLength: Int64;
    property AutoTrim: Boolean read FAutoTrim write SetAutoTrim;
    property MaxTokensForQuery: Int64 read FMaxTokensForQuery write SetMaxTokensForQuery;
    property MaxTokensOfModel: Int64 read FMaxTokensOfModel write SetMaxTokensOfModel;
    property OnCalcContentTokens: TOnCalcTokens read FOnCalcContentTokens write SetOnCalcContentTokens;
    procedure DeleteByTag(const Tag: string);
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

procedure TChatHistory.DeleteByTag(const Tag: string);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].Tag = Tag then
    begin
      Delete(i);
      Exit;
    end;
end;

procedure TChatHistory.SetContentByTag(const Tag, Text: string);
var
  i: Integer;
  Item: TChatMessageBuild;
begin
  for i := 0 to Count - 1 do
    if Items[i].Tag = Tag then
    begin
      Item := Items[i];
      Item.Content := Text;
      Items[i] := Item;
      Exit;
    end;
end;

procedure TChatHistory.New(Role: TMessageRole; Content, Tag: string);
var
  Item: TChatMessageBuild;
begin
  Item := TChatMessageBuild.Create(Role, Content);
  Item.Tag := Tag;
  Add(Item);
end;

procedure TChatHistory.NewAsistantFunc(const FuncName, Args, Tag: string);
var
  Item: TChatMessageBuild;
begin
  Item := TChatMessageBuild.AssistantFunc(FuncName, Args);
  Item.Tag := Tag;
  Add(Item);
end;

procedure TChatHistory.NewFunc(const FuncName, FuncResult, Tag: string);
var
  Item: TChatMessageBuild;
begin
  Item := TChatMessageBuild.Func(FuncResult, FuncName);
  Item.Tag := Tag;
  Add(Item);
end;

procedure TChatHistory.Notify(const Item: TChatMessageBuild; Action: TCollectionNotification);
var
  LastItem: TChatMessageBuild;
  NeedLen: Int64;
begin
  inherited;
  if FAutoTrim and (Action = TCollectionNotification.cnAdded) then
  begin
    while TextLength + FMaxTokensForQuery > FMaxTokensOfModel do
      if Count = 1 then
      begin
        LastItem := Items[0];
        NeedLen := LastItem.Content.Length - FMaxTokensForQuery;
        LastItem.Content := LastItem.Content.Substring(LastItem.Content.Length - NeedLen, NeedLen);
        Items[0] := LastItem;
      end
      else
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
  if FMaxTokensForQuery <= 0 then
    FMaxTokensForQuery := DEFULT_MAX_TOKENS;
end;

procedure TChatHistory.SetMaxTokensOfModel(const Value: Int64);
begin
  FMaxTokensOfModel := Value;
  if FMaxTokensOfModel <= 0 then
    FMaxTokensOfModel := DEFULT_MODEL_TOKENS_LIMIT;
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


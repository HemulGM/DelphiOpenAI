unit Chat.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types,
  Data.Bind.Components, Data.Bind.ObjectScope, REST.Client, OpenAI, FMX.Styles,
  OpenAI.Component.Chat, FMX.Memo.Types, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, OpenAI.Component.Functions, FMX.Layouts, FMX.ListBox,
  OpenAI.Types;

type
  TFormChat = class(TForm)
    OpenAIClient1: TOpenAIClient;
    OpenAIChat1: TOpenAIChat;
    MemoMessages: TMemo;
    MemoMessage: TMemo;
    ButtonSend: TButton;
    ButtonStreamSend: TButton;
    AniIndicatorBusy: TAniIndicator;
    OpenAIChatFunctions1: TOpenAIChatFunctions;
    ListBox1: TListBox;
    ButtonAttach: TButton;
    ButtonRemoveAttach: TButton;
    StyleBook1: TStyleBook;
    OpenDialogImg: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure OpenAIChat1Chat(Sender: TObject; Event: TChat);
    procedure OpenAIChat1Error(Sender: TObject; Error: Exception);
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonStreamSendClick(Sender: TObject);
    procedure OpenAIChat1BeginWork(Sender: TObject);
    procedure OpenAIChat1ChatDelta(Sender: TObject; Event: TChat; IsDone: Boolean);
    procedure OpenAIChat1EndWork(Sender: TObject);
    procedure FuncGetCurrentWeather(Sender: TObject; const Args: string; out Result: string);
    procedure ButtonAttachClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormChat: TFormChat;

implementation

uses
  System.JSON, System.IOUtils, OpenAI.Chat, OpenAI.Utils.Base64;

{$R *.fmx}

procedure TFormChat.ButtonAttachClick(Sender: TObject);
begin
  if OpenDialogImg.Execute then
  begin
    var Item := TListBoxItem.Create(ListBox1);
    Item.Text := TPath.GetFileName(OpenDialogImg.FileName);
    Item.TagString := OpenDialogImg.FileName;
    Item.ItemData.Bitmap.LoadThumbnailFromFile(OpenDialogImg.FileName, 75, 75);
    ListBox1.AddObject(Item);
  end;
end;

procedure TFormChat.ButtonSendClick(Sender: TObject);
begin
  MemoMessages.Lines.Add('User: ' + MemoMessage.Text);
  MemoMessages.Lines.Add('');
  OpenAIChat1.Stream := False;
  var Content: TArray<TMessageContent>;

  if not MemoMessage.Text.IsEmpty then
    Content := Content + [TMessageContent.CreateText(MemoMessage.Text)];

  for var i := 0 to ListBox1.Count - 1 do
    Content := Content + [TMessageContent.CreateImage(FileToBase64(ListBox1.ListItems[i].TagString))];

  OpenAIChat1.Send([TChatMessageBuild.User(Content)]);
end;

procedure TFormChat.ButtonStreamSendClick(Sender: TObject);
begin
  MemoMessages.Lines.Add('User: ' + MemoMessage.Text);
  MemoMessages.Lines.Add('');
  OpenAIChat1.Stream := True;
  OpenAIChat1.Send([TChatMessageBuild.User(MemoMessage.Text)]);
  MemoMessages.Lines.Add('Assistant: ');
end;

procedure TFormChat.FormCreate(Sender: TObject);
begin
  OpenAIClient1.Token := {$INCLUDE token.txt};

  OpenAIClient1.API.CustomHeaders := OpenAIClient1.API.CustomHeaders + [THeaderItem.Create('OpenAI-Beta', 'assistants=v2')];
end;

procedure TFormChat.OpenAIChat1BeginWork(Sender: TObject);
begin
  AniIndicatorBusy.Visible := True;
end;

procedure TFormChat.OpenAIChat1Chat(Sender: TObject; Event: TChat);
begin
  MemoMessages.Lines.Add('Assistant: ' + Event.Choices[0].Message.Content);
  MemoMessages.Lines.Add('');
end;

procedure TFormChat.OpenAIChat1ChatDelta(Sender: TObject; Event: TChat; IsDone: Boolean);
begin
  if Assigned(Event) then
  begin
    if Event.Choices[0].FinishReason = TFinishReason.FunctionCall then
    begin
      MemoMessages.Lines.Add('Call function ' + Event.Choices[0].Delta.FunctionCall.Name);
    end
    else
      MemoMessages.Text := MemoMessages.Text + Event.Choices[0].Delta.Content;
  end;
  if IsDone then
    MemoMessages.Lines.Add('');
end;

procedure TFormChat.OpenAIChat1EndWork(Sender: TObject);
begin
  AniIndicatorBusy.Visible := False;
end;

procedure TFormChat.OpenAIChat1Error(Sender: TObject; Error: Exception);
begin
  MemoMessages.Lines.Add('Error: ' + Error.Message);
  MemoMessages.Lines.Add('');
end;

procedure TFormChat.FuncGetCurrentWeather(Sender: TObject; const Args: string; out Result: string);
var
  JSON: TJSONObject;
  Location: string;
  UnitKind: string;
begin
  Result := '';
  Location := '';
  UnitKind := '';

  // Parse arguments
  try
    JSON := TJSONObject.ParseJSONValue(Args) as TJSONObject;
    if Assigned(JSON) then
    try
      Location := JSON.GetValue('location', '');
      UnitKind := JSON.GetValue('unit', '');
    finally
      JSON.Free;
    end;
  except
    Location := '';
  end;

  // Invalid arguments
  if Location.IsEmpty then
    Exit;

  // Generate response
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('location', Location);
    JSON.AddPair('unit', UnitKind);

    JSON.AddPair('temperature', TJSONNumber.Create(72));
    JSON.AddPair('forecast', TJSONArray.Create('sunny', 'windy'));

    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.


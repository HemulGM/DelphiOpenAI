unit OpenAI.Component.Chat;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  System.Threading, OpenAI, OpenAI.Chat, OpenAI.Component.Functions,
  OpenAI.Utils.ObjectHolder, OpenAI.Component.ChatHistory;

type
  TChat = OpenAI.Chat.TChat;

  TChatMessageBuild = OpenAI.Chat.TChatMessageBuild;

  TOnChat = procedure(Sender: TObject; Event: TChat) of object;

  TOnChatDelta = procedure(Sender: TObject; Event: TChat; IsDone: Boolean) of object;

  TOnFunctionCall = procedure(Sender: TObject; const FuncName, FuncArgs: string) of object;

  TOnError = procedure(Sender: TObject; Error: Exception) of object;

  ExceptionChatBusy = class(Exception);

  TOpenAIChatCustom = class(TComponent)
  private
    FClient: TOpenAIClient;
    FTask: ITask;
    FModel: string;
    FN: Integer;
    FPresencePenalty: Single;
    FStream: Boolean;
    FMaxTokens: Integer;
    FStop: TStringList;
    FTopP: Single;
    FTemperature: Single;
    FUser: string;
    FFrequencyPenalty: Single;
    FOnChat: TOnChat;
    FSynchronize: Boolean;
    FOnError: TOnError;
    FOnBeginWork: TNotifyEvent;
    FOnEndWork: TNotifyEvent;
    FOnChatDelta: TOnChatDelta;
    FDoStreamStop: Boolean;
    FFunctions: TOpenAIChatFunctions;
    FOnFunctionCall: TOnFunctionCall;
    FHistory: TOpenAIChatHistoryCustom;
    procedure SetClient(const Value: TOpenAIClient);
    procedure SetModel(const Value: string);
    procedure SetFrequencyPenalty(const Value: Single);
    procedure SetMaxTokens(const Value: Integer);
    procedure SetN(const Value: Integer);
    procedure SetPresencePenalty(const Value: Single);
    procedure SetStream(const Value: Boolean);
    procedure SetTemperature(const Value: Single);
    procedure SetTopP(const Value: Single);
    procedure SetUser(const Value: string);
    procedure SetOnChat(const Value: TOnChat);
    procedure CheckTask;
    procedure SetSynchronize(const Value: Boolean);
    procedure SetOnError(const Value: TOnError);
    procedure InternalSend(const Messages: TArray<TChatMessageBuild>);
    procedure InternalStreamSend(const Messages: TArray<TChatMessageBuild>);
    function GetIsBusy: Boolean;
    procedure SetOnBeginWork(const Value: TNotifyEvent);
    procedure SetOnEndWork(const Value: TNotifyEvent);
    procedure SetOnChatDelta(const Value: TOnChatDelta);
    procedure SetFunctions(const Value: TOpenAIChatFunctions);
    procedure SetOnFunctionCall(const Value: TOnFunctionCall);
    procedure DoFunctionCall(ChatFunctions: TArray<TChatToolCall>);
    procedure SetHistory(const Value: TOpenAIChatHistoryCustom);
  protected
    procedure DoChat(Chat: TChat); virtual;
    procedure DoChatDelta(Chat: TChat; IsDone: Boolean); virtual;
    procedure DoError(E: Exception); virtual;
    procedure DoBeginWork; virtual;
    procedure DoEndWork; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    property Client: TOpenAIClient read FClient write SetClient;
    property Functions: TOpenAIChatFunctions read FFunctions write SetFunctions;
    property History: TOpenAIChatHistoryCustom read FHistory write SetHistory;
    property Model: string read FModel write SetModel;
    property Temperature: Single read FTemperature write SetTemperature;
    property TopP: Single read FTopP write SetTopP;
    property N: Integer read FN write SetN;
    property Stream: Boolean read FStream write SetStream;
    property Stop: TStringList read FStop;
    property MaxTokens: Integer read FMaxTokens write SetMaxTokens;
    property PresencePenalty: Single read FPresencePenalty write SetPresencePenalty;
    property FrequencyPenalty: Single read FFrequencyPenalty write SetFrequencyPenalty;
    property User: string read FUser write SetUser;
    property Synchronize: Boolean read FSynchronize write SetSynchronize;
  public
    property IsBusy: Boolean read GetIsBusy;
  public
    procedure Send(const Messages: TArray<TChatMessageBuild>);
    procedure StopStream;
  public
    property OnChat: TOnChat read FOnChat write SetOnChat;
    property OnChatDelta: TOnChatDelta read FOnChatDelta write SetOnChatDelta;
    property OnFunctionCall: TOnFunctionCall read FOnFunctionCall write SetOnFunctionCall;
    property OnError: TOnError read FOnError write SetOnError;
    property OnBeginWork: TNotifyEvent read FOnBeginWork write SetOnBeginWork;
    property OnEndWork: TNotifyEvent read FOnEndWork write SetOnEndWork;
  end;

  TOpenAIChat = class(TOpenAIChatCustom)
  published
    property Client;
    property History;
    property Functions;
    /// <summary>
    /// ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/models/model-endpoint-compatibility</seealso>
    property Model;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic.
    /// We generally recommend altering this or top_p but not both.
    /// </summary>
    property Temperature;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the
    /// results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10%
    /// probability mass are considered.
    /// We generally recommend altering this or temperature but not both.
    /// </summary>
    property TopP;
    /// <summary>
    /// How many chat completion choices to generate for each input message.
    /// </summary>
    property N default 1;
    /// <summary>
    /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as
    /// data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
    /// </summary>
    property Stream default False;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens.
    /// </summary>
    property Stop;
    /// <summary>
    /// The maximum number of tokens allowed for the generated answer. By default, the number of
    /// tokens the model can return will be (4096 - prompt tokens).
    /// </summary>
    property MaxTokens default 1024;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far,
    /// increasing the model's likelihood to talk about new topics.
    /// </summary>
    property PresencePenalty;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far,
    /// decreasing the model's likelihood to repeat the same line verbatim.
    /// </summary>
    property FrequencyPenalty;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    property User;
    property Synchronize default True;
  published
    property OnChat;
    property OnChatDelta;
    property OnError;
    property OnBeginWork;
    property OnEndWork;
  end;

implementation

uses
  OpenAI.Chat.Functions;

{ TOpenAIChatCustom }

procedure TOpenAIChatCustom.CheckTask;
begin
  if FTask <> nil then
    raise ExceptionChatBusy.Create('Already running');
end;

constructor TOpenAIChatCustom.Create(AOwner: TComponent);
begin
  inherited;
  FStop := TStringList.Create;
  FTemperature := 1;
  FStream := False;
  FModel := 'gpt-4';
  FTopP := 1;
  FN := 1;
  FMaxTokens := 1024;
  FPresencePenalty := 0;
  FFrequencyPenalty := 0;
  FSynchronize := True;
end;

destructor TOpenAIChatCustom.Destroy;
begin
  FDoStreamStop := True;
  if Assigned(FTask) then
  begin
    var WTask := FTask;
    WTask.Wait;
  end;
  FStop.Free;
  inherited;
end;

procedure TOpenAIChatCustom.DoBeginWork;
begin
  if Assigned(FOnBeginWork) then
    FOnBeginWork(Self);
end;

procedure TOpenAIChatCustom.DoFunctionCall(ChatFunctions: TArray<TChatToolCall>);
begin
  var FuncMessages: TArray<TChatMessageBuild> := [];
  for var Func in ChatFunctions do
  begin
    if Assigned(FOnFunctionCall) then
      FOnFunctionCall(Self, Func.&Function.Name, Func.&Function.Arguments);
    FuncMessages := FuncMessages +
      [TChatMessageBuild.Func(FFunctions.Call(Func.&Function.Name, Func.&Function.Arguments), Func.&Function.Name)];
  end;
  if Length(FuncMessages) > 0 then
    InternalSend(FuncMessages);
end;

procedure TOpenAIChatCustom.DoChat(Chat: TChat);
begin
  if Length(Chat.Choices) > 0 then
    if Assigned(Chat.Choices[0].Message) then
      if Length(Chat.Choices[0].Message.ToolCalls) > 0 then
      begin
        DoFunctionCall(Chat.Choices[0].Message.ToolCalls);
        Exit;
      end;

  if Assigned(FOnChat) then
    FOnChat(Self, Chat);
end;

procedure TOpenAIChatCustom.DoChatDelta(Chat: TChat; IsDone: Boolean);
begin
  if Assigned(FOnChatDelta) then
    FOnChatDelta(Self, Chat, IsDone);
end;

procedure TOpenAIChatCustom.DoEndWork;
begin
  FTask := nil;
  if Assigned(FOnEndWork) then
    FOnEndWork(Self);
end;

procedure TOpenAIChatCustom.DoError(E: Exception);
begin
  if Assigned(FOnError) then
    FOnError(Self, E);
end;

function TOpenAIChatCustom.GetIsBusy: Boolean;
begin
  Result := FTask <> nil;
end;

procedure TOpenAIChatCustom.Send(const Messages: TArray<TChatMessageBuild>);
begin
  CheckTask;
  if Assigned(FHistory) then
  begin
    FHistory.Items.AddRange(Messages);
    if not Stream then
      InternalSend(FHistory.Items.ToArray)
    else
      InternalStreamSend(FHistory.Items.ToArray);
  end
  else
  begin
    if not Stream then
      InternalSend(Messages)
    else
      InternalStreamSend(Messages);
  end;
end;

procedure TOpenAIChatCustom.InternalSend(const Messages: TArray<TChatMessageBuild>);
begin
  var CurrentChat := Self;
  var FMessages := Messages;
  var FSync := Self.FSynchronize;
  var FModel := Self.FModel;
  var FTemperature := Self.FTemperature;
  var FTopP := Self.FTopP;
  var FN := Self.FN;
  var FStop := Self.FStop.ToStringArray;
  var FMaxTokens := Self.FMaxTokens;
  var FPresencePenalty := Self.FPresencePenalty;
  var FFrequencyPenalty := Self.FFrequencyPenalty;
  var FUser := Self.FUser;
  var FChatTools: TArray<TChatToolParam> := [];

  if Assigned(FFunctions) then
    for var Item in FFunctions.GetList do
      FChatTools := FChatTools + [TChatToolFunctionParam.Create(Item)];

  FTask := TaskRun(Self,
    procedure(Holder: IComponentHolder)
    begin
      try
        var Chat: TChat;
        try
          Chat := FClient.Chat.Create(
            procedure(Params: TChatParams)
            begin
              Params.Messages(FMessages);
              Params.Model(FModel);
              Params.Temperature(FTemperature);
              Params.TopP(FTopP);
              Params.N(FN);
              if Length(FStop) > 0 then
                Params.Stop(FStop);
              Params.MaxTokens(FMaxTokens);
              Params.PresencePenalty(FPresencePenalty);
              Params.FrequencyPenalty(FFrequencyPenalty);
              Params.User(FUser);
              if Length(FChatTools) > 0 then
                Params.Tools(FChatTools);
            end);
          if not Holder.IsLive then
          begin
            Chat.Free;
            Exit;
          end;
        except
          on E: Exception do
          begin
            if FSync then
            begin
              var Err := AcquireExceptionObject;
              Queue(
                procedure
                begin
                  try
                    if Holder.IsLive then
                      CurrentChat.DoError(E);
                  finally
                    Err.Free;
                  end;
                end);
            end
            else
            begin
              if Holder.IsLive then
                CurrentChat.DoError(E);
            end;
            Exit;
          end;
        end;
        if FSync then
          Queue(
            procedure
            begin
              try
                if Holder.IsLive then
                  CurrentChat.DoChat(Chat);
              finally
                Chat.Free;
              end;
            end)
        else
        try
          if Holder.IsLive then
            CurrentChat.DoChat(Chat);
        finally
          Chat.Free;
        end;
      finally
        if Holder.IsLive then
          CurrentChat.DoEndWork;
      end;
    end);
  DoBeginWork;
  FTask.Start;
end;

procedure TOpenAIChatCustom.InternalStreamSend(const Messages: TArray<TChatMessageBuild>);
begin
  var CurrentChat := Self;
  var FMessages := Messages;
  var FSync := Self.FSynchronize;
  var FModel := Self.FModel;
  var FTemperature := Self.FTemperature;
  var FTopP := Self.FTopP;
  var FN := Self.FN;
  var FStop := Self.FStop.ToStringArray;
  var FMaxTokens := Self.FMaxTokens;
  var FPresencePenalty := Self.FPresencePenalty;
  var FFrequencyPenalty := Self.FFrequencyPenalty;
  var FUser := Self.FUser;
  var FChatTools: TArray<TChatToolParam> := [];

  if Assigned(FFunctions) then
    for var Item in FFunctions.GetList do
      FChatTools := FChatTools + [TChatToolFunctionParam.Create(Item)];

  FDoStreamStop := False;
  FTask := TaskRun(Self,
    procedure(Holder: IComponentHolder)
    begin
      try
        try
          var Succ := FClient.Chat.CreateStream(
            procedure(Params: TChatParams)
            begin
              Params.Messages(FMessages);
              Params.Model(FModel);
              Params.Temperature(FTemperature);
              Params.TopP(FTopP);
              Params.N(FN);
              if Length(FStop) > 0 then
                Params.Stop(FStop);
              Params.Stream;
              Params.MaxTokens(FMaxTokens);
              Params.PresencePenalty(FPresencePenalty);
              Params.FrequencyPenalty(FFrequencyPenalty);
              Params.User(FUser);
              if Length(FChatTools) > 0 then
                Params.Tools(FChatTools);
            end,
            procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
            begin
              if FDoStreamStop then
              begin
                Cancel := True;
                Exit;
              end;
              if not Holder.IsLive then
              begin
                Cancel := True;
                Exit;
              end;
              if FSync then
              begin
                var FChat := Chat;
                Chat := nil;
                Queue(
                  procedure
                  begin
                    try
                      if Holder.IsLive then
                        CurrentChat.DoChatDelta(FChat, IsDone);
                    finally
                      FChat.Free;
                    end;
                  end)
              end
              else
              begin
                if Holder.IsLive then
                  CurrentChat.DoChatDelta(Chat, IsDone);
              end;
            end);
          if not Succ then
            raise Exception.Create('Error');
        except
          on E: Exception do
          begin
            if FSync then
            begin
              var Err := AcquireExceptionObject;
              Queue(
                procedure
                begin
                  try
                    if Holder.IsLive then
                      CurrentChat.DoError(E);
                  finally
                    Err.Free;
                  end;
                end);
            end
            else
            begin
              if Holder.IsLive then
                CurrentChat.DoError(E);
            end;
            Exit;
          end;
        end;
      finally
        if Holder.IsLive then
          CurrentChat.DoEndWork;
      end;
    end);
  DoBeginWork;
  FTask.Start;
end;

procedure TOpenAIChatCustom.SetClient(const Value: TOpenAIClient);
begin
  FClient := Value;
end;

procedure TOpenAIChatCustom.SetFrequencyPenalty(const Value: Single);
begin
  FFrequencyPenalty := Value;
end;

procedure TOpenAIChatCustom.SetFunctions(const Value: TOpenAIChatFunctions);
begin
  FFunctions := Value;
end;

procedure TOpenAIChatCustom.SetHistory(const Value: TOpenAIChatHistoryCustom);
begin
  FHistory := Value;
end;

procedure TOpenAIChatCustom.SetMaxTokens(const Value: Integer);
begin
  FMaxTokens := Value;
end;

procedure TOpenAIChatCustom.SetModel(const Value: string);
begin
  FModel := Value;
end;

procedure TOpenAIChatCustom.SetN(const Value: Integer);
begin
  FN := Value;
end;

procedure TOpenAIChatCustom.SetOnBeginWork(const Value: TNotifyEvent);
begin
  FOnBeginWork := Value;
end;

procedure TOpenAIChatCustom.SetOnChat(const Value: TOnChat);
begin
  FOnChat := Value;
end;

procedure TOpenAIChatCustom.SetOnChatDelta(const Value: TOnChatDelta);
begin
  FOnChatDelta := Value;
end;

procedure TOpenAIChatCustom.SetOnEndWork(const Value: TNotifyEvent);
begin
  FOnEndWork := Value;
end;

procedure TOpenAIChatCustom.SetOnError(const Value: TOnError);
begin
  FOnError := Value;
end;

procedure TOpenAIChatCustom.SetOnFunctionCall(const Value: TOnFunctionCall);
begin
  FOnFunctionCall := Value;
end;

procedure TOpenAIChatCustom.SetPresencePenalty(const Value: Single);
begin
  FPresencePenalty := Value;
end;

procedure TOpenAIChatCustom.SetStream(const Value: Boolean);
begin
  FStream := Value;
end;

procedure TOpenAIChatCustom.SetSynchronize(const Value: Boolean);
begin
  FSynchronize := Value;
end;

procedure TOpenAIChatCustom.SetTemperature(const Value: Single);
begin
  FTemperature := Value;
end;

procedure TOpenAIChatCustom.SetTopP(const Value: Single);
begin
  FTopP := Value;
end;

procedure TOpenAIChatCustom.SetUser(const Value: string);
begin
  FUser := Value;
end;

procedure TOpenAIChatCustom.StopStream;
begin
  FDoStreamStop := True;
end;

end.


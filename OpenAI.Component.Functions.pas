unit OpenAI.Component.Functions;

interface

uses
  System.Classes, System.SysUtils, OpenAI.Chat.Functions;

type
  TChatFunction = OpenAI.Chat.Functions.TChatFunction;

  EFunctionNotImplemented = class(Exception);

  EFunctionNotFound = class(Exception);

  TOnFunctionExecute = procedure(Sender: TObject; const Args: string; out Result: string) of object;

  TChatFunctionContainer = class(TChatFunction, IChatFunction)
  private
    FName: string;
    FParameters: string;
    FDescription: string;
    FStrict: Boolean;
    FFunction: TOnFunctionExecute;
    procedure SetDescription(const Value: string);
    procedure SetName(const Value: string);
    procedure SetParameters(const Value: string);
    procedure SetStrict(const Value: Boolean);
  protected
    function GetStrict: Boolean; override;
    function GetDescription: string; override;
    function GetName: string; override;
    function GetParameters: string; override;
  public
    function Execute(const Args: string): string; override;
    property Description: string read GetDescription write SetDescription;
    property Name: string read GetName write SetName;
    property Parameters: string read GetParameters write SetParameters;
    property Strict: Boolean read GetStrict write SetStrict;
  end;

  TFunctionCollectionItem = class(TCollectionItem)
  private
    FFunction: IChatFunction;
    function GetDescription: string;
    function GetName: string;
    function GetParameters: string;
    procedure SetDescription(const Value: string);
    procedure SetName(const Value: string);
    procedure SetParameters(const Value: string);
    procedure SetOnFunctionExecute(const Value: TOnFunctionExecute);
    function GetOnFunctionExecute: TOnFunctionExecute;
    function GetStrict: Boolean;
    procedure SetStrict(const Value: Boolean);
  protected
    function GetDisplayName: string; override;
  published
    property Description: string read GetDescription write SetDescription;
    property Name: string read GetName write SetName;
    property Parameters: string read GetParameters write SetParameters;
    property Strict: Boolean read GetStrict write SetStrict;
    property OnFunctionExecute: TOnFunctionExecute read GetOnFunctionExecute write SetOnFunctionExecute;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  end;

  TFunctionCollection = class(TOwnedCollection)
  end;

  TOpenAIChatFunctions = class(TComponent)
  private
    FItems: TFunctionCollection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetList: TArray<IChatFunction>;
    function Call(const FuncName, FuncArgs: string): string;
  published
    property Items: TFunctionCollection read FItems write FItems;
  end;

implementation

{ TOpenAIChatFunctions }

function TOpenAIChatFunctions.Call(const FuncName, FuncArgs: string): string;
begin
  for var Item in FItems do
    if TFunctionCollectionItem(Item).Name = FuncName then
      Exit(TFunctionCollectionItem(Item).FFunction.Execute(FuncArgs));
  raise EFunctionNotFound.CreateFmt('Function "%s" not found', [FuncName]);
end;

constructor TOpenAIChatFunctions.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TFunctionCollection.Create(Self, TFunctionCollectionItem);
end;

destructor TOpenAIChatFunctions.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TOpenAIChatFunctions.GetList: TArray<IChatFunction>;
begin
  SetLength(Result, FItems.Count);
  var i: Integer := 0;
  for var Item in FItems do
  begin
    Result[i] := TFunctionCollectionItem(Item).FFunction;
    Inc(i);
  end;
end;

{ TFunctionCollectionItem }

constructor TFunctionCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  FFunction := TChatFunctionContainer.Create;
end;

destructor TFunctionCollectionItem.Destroy;
begin
  FFunction := nil;
  inherited;
end;

function TFunctionCollectionItem.GetDescription: string;
begin
  Result := FFunction.Description;
end;

function TFunctionCollectionItem.GetDisplayName: string;
begin
  Result := FFunction.Name;
end;

function TFunctionCollectionItem.GetName: string;
begin
  Result := FFunction.Name;
end;

function TFunctionCollectionItem.GetOnFunctionExecute: TOnFunctionExecute;
begin
  Result := TChatFunctionContainer(FFunction).FFunction;
end;

function TFunctionCollectionItem.GetParameters: string;
begin
  Result := FFunction.Parameters;
end;

function TFunctionCollectionItem.GetStrict: Boolean;
begin
  Result := TChatFunctionContainer(FFunction).FStrict;
end;

procedure TFunctionCollectionItem.SetDescription(const Value: string);
begin
  TChatFunctionContainer(FFunction).FDescription := Value;
end;

procedure TFunctionCollectionItem.SetName(const Value: string);
begin
  TChatFunctionContainer(FFunction).FName := Value;
end;

procedure TFunctionCollectionItem.SetOnFunctionExecute(const Value: TOnFunctionExecute);
begin
  TChatFunctionContainer(FFunction).FFunction := Value;
end;

procedure TFunctionCollectionItem.SetParameters(const Value: string);
begin
  TChatFunctionContainer(FFunction).FParameters := Value;
end;

procedure TFunctionCollectionItem.SetStrict(const Value: Boolean);
begin
  TChatFunctionContainer(FFunction).FStrict := Value;
end;

{ TChatFunctionContainer }

function TChatFunctionContainer.Execute(const Args: string): string;
begin
  if Assigned(FFunction) then
    FFunction(Self, Args, Result)
  else
    raise EFunctionNotImplemented.Create('Function not implemented');
end;

function TChatFunctionContainer.GetDescription: string;
begin
  Result := FDescription;
end;

function TChatFunctionContainer.GetName: string;
begin
  Result := FName;
end;

function TChatFunctionContainer.GetParameters: string;
begin
  Result := FParameters;
end;

function TChatFunctionContainer.GetStrict: Boolean;
begin
  Result := FStrict;
end;

procedure TChatFunctionContainer.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TChatFunctionContainer.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TChatFunctionContainer.SetParameters(const Value: string);
begin
  FParameters := Value;
end;

procedure TChatFunctionContainer.SetStrict(const Value: Boolean);
begin
  FStrict := Value;
end;

end.


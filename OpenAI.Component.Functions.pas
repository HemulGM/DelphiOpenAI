unit OpenAI.Component.Functions;

interface

uses
  System.Classes, OpenAI.Chat.Functions;

type
  TChatFunction = OpenAI.Chat.Functions.TChatFunction;

  TOnFunctionExecute = procedure(Sender: TObject; const Args: string; out Result: string) of object;

  TChatFunctionContainer = class(TChatFunction, IChatFunction)
  private
    FName: string;
    FParameters: string;
    FDescription: string;
    procedure SetDescription(const Value: string);
    procedure SetName(const Value: string);
    procedure SetParameters(const Value: string);
  protected
    function GetDescription: string; override;
    function GetName: string; override;
    function GetParameters: string; override;
  public
    function Execute(const Args: string): string; override;
    property Description: string read GetDescription write SetDescription;
    property Name: string read GetName write SetName;
    property Parameters: string read GetParameters write SetParameters;
  end;

  TFunctionCollectionItem = class(TCollectionItem)
  private
    FFunction: IChatFunction;
    FOnFunctionExecute: TOnFunctionExecute;
    function GetDescription: string;
    function GetName: string;
    function GetParameters: string;
    procedure SetDescription(const Value: string);
    procedure SetName(const Value: string);
    procedure SetParameters(const Value: string);
    procedure SetOnFunctionExecute(const Value: TOnFunctionExecute);
  protected
    function GetDisplayName: string; override;
  published
    property Description: string read GetDescription write SetDescription;
    property Name: string read GetName write SetName;
    property Parameters: string read GetParameters write SetParameters;
    property OnFunctionExecute: TOnFunctionExecute read FOnFunctionExecute write SetOnFunctionExecute;
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
  published
    property Items: TFunctionCollection read FItems write FItems;
  end;

implementation

{ TOpenAIChatFunctions }

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

function TFunctionCollectionItem.GetParameters: string;
begin
  Result := FFunction.Parameters;
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
  FOnFunctionExecute := Value;
end;

procedure TFunctionCollectionItem.SetParameters(const Value: string);
begin
  TChatFunctionContainer(FFunction).FParameters := Value;
end;

{ TChatFunctionContainer }

function TChatFunctionContainer.Execute(const Args: string): string;
begin
  Result := '';
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

end.


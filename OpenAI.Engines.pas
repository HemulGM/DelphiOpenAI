unit OpenAI.Engines;

interface

uses
  System.SysUtils, OpenAI.API;

type
  TEngine = class
  private
    FId: string;
    FObject: string;
    FOwned_by: string;
    FReady: Boolean;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property OwnedBy: string read FOwned_by write FOwned_by;
    property Ready: Boolean read FReady write FReady;
  end;

  TEngines = class
  private
    FData: TArray<TEngine>;
    FObject: string;
  public
    property Data: TArray<TEngine> read FData write FData;
    property &Object: string read FObject write FObject;
    destructor Destroy; override;
  end;

  TEnginesRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Lists the currently available (non-finetuned) models, and provides basic information about each one such as the owner and availability.
    /// </summary>
    function List: TEngines; deprecated 'The Engines endpoints are deprecated. Please use their replacement, Models, instead.';
    /// <summary>
    /// Retrieves a model instance, providing basic information about it such as the owner and availability.
    /// </summary>
    /// <param name="const Name: string">The ID of the engine to use for this request</param>
    function Retrieve(const EngineId: string): TEngine; deprecated 'The Engines endpoints are deprecated. Please use their replacement, Models, instead.';
  end;

implementation

{ TEnginesRoute }

function TEnginesRoute.List: TEngines;
begin
  Result := API.Get<TEngines>('engines');
end;

function TEnginesRoute.Retrieve(const EngineId: string): TEngine;
begin
  Result := API.Get<TEngine>('engines' + '/' + EngineId);
end;

{ TEngines }

destructor TEngines.Destroy;
var
  Item: TEngine;
begin
  for Item in FData do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

end.


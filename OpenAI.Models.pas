unit OpenAI.Models;

interface

uses
  System.SysUtils, OpenAI.API;

type
  TModelPermission = class
  private
    FAllow_create_engine: Boolean;
    FAllow_fine_tuning: Boolean;
    FAllow_logprobs: Boolean;
    FAllow_sampling: Boolean;
    FAllow_search_indices: Boolean;
    FAllow_view: Boolean;
    FCreated: Int64;
    FId: string;
    FIs_blocking: Boolean;
    FObject: string;
    FOrganization: string;
  public
    property AllowCreateEngine: Boolean read FAllow_create_engine write FAllow_create_engine;
    property AllowFineTuning: Boolean read FAllow_fine_tuning write FAllow_fine_tuning;
    property AllowLogprobs: Boolean read FAllow_logprobs write FAllow_logprobs;
    property AllowSampling: Boolean read FAllow_sampling write FAllow_sampling;
    property AllowSearchIndices: Boolean read FAllow_search_indices write FAllow_search_indices;
    property AllowView: Boolean read FAllow_view write FAllow_view;
    property Created: Int64 read FCreated write FCreated;
    property Id: string read FId write FId;
    property IsBlocking: Boolean read FIs_blocking write FIs_blocking;
    property &Object: string read FObject write FObject;
    property Organization: string read FOrganization write FOrganization;
  end;

  /// <summary>
  /// Describes an OpenAI model offering that can be used with the API.
  /// </summary>
  TModel = class
  private
    FCreated: Int64;
    FId: string;
    FObject: string;
    FOwned_by: string;
    FPermission: TArray<TModelPermission>;
    FRoot: string;
  public
    /// <summary>
    /// The Unix timestamp (in seconds) when the model was created.
    /// </summary>
    property Created: Int64 read FCreated write FCreated;
    /// <summary>
    /// The model identifier, which can be referenced in the API endpoints.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type, which is always "model".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The organization that owns the model.
    /// </summary>
    property OwnedBy: string read FOwned_by write FOwned_by;
    /// <summary>
    /// May be depricated
    /// </summary>
    property Permission: TArray<TModelPermission> read FPermission write FPermission;
    /// <summary>
    /// May be depricated
    /// </summary>
    property Root: string read FRoot write FRoot;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Lists the currently available models, and provides basic information about each one such as the owner and availability.
  /// </summary>
  TModels = class
  private
    FData: TArray<TModel>;
    FObject: string;
  public
    property Data: TArray<TModel> read FData write FData;
    property &Object: string read FObject write FObject;
    destructor Destroy; override;
  end;

  TDeletionStatus = class
  private
    FDeleted: Boolean;
    FId: string;
    FObject: string;
  public
    property Deleted: Boolean read FDeleted write FDeleted;
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
  end;

  TModelsRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Lists the currently available models, and provides basic information about each one such as the owner and availability.
    /// </summary>
    function List: TModels;
    /// <summary>
    /// Retrieves a model instance, providing basic information about the model such as the owner and permissioning.
    /// </summary>
    /// <param name="Model">The ID of the model to use for this request</param>
    function Retrieve(const Model: string): TModel;
    /// <summary>
    /// Delete a fine-tuned model. You must have the Owner role in your organization to delete a model.
    /// </summary>
    function DeleteFineTuneModel(const Model: string): TDeletionStatus;
  end;

implementation

{ TModelsRoute }

function TModelsRoute.DeleteFineTuneModel(const Model: string): TDeletionStatus;
begin
  Result := API.Delete<TDeletionStatus>('models/' + Model);
end;

function TModelsRoute.List: TModels;
begin
  Result := API.Get<TModels>('models');
end;

function TModelsRoute.Retrieve(const Model: string): TModel;
begin
  Result := API.Get<TModel>('models/' + Model);
end;

{ TModels }

destructor TModels.Destroy;
var
  Item: TModel;
begin
  for Item in FData do
    Item.Free;
  inherited;
end;

{ TModel }

destructor TModel.Destroy;
var
  Item: TModelPermission;
begin
  for Item in FPermission do
    Item.Free;
  inherited;
end;

end.


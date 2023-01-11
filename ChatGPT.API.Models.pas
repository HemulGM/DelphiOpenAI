unit ChatGPT.API.Models;

interface

type
  TGPTModelPermission = class
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

  TGPTModel = class
  private
    FCreated: Int64;
    FId: string;
    FObject: string;
    FOwned_by: string;
    FPermission: TArray<TGPTModelPermission>;
    FRoot: string;
  public
    property Created: Int64 read FCreated write FCreated;
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property OwnedBy: string read FOwned_by write FOwned_by;
    property Permission: TArray<TGPTModelPermission> read FPermission write FPermission;
    property Root: string read FRoot write FRoot;
    destructor Destroy; override;
  end;

  TGPTModels = class
  private
    FData: TArray<TGPTModel>;
    FObject: string;
  public
    property Data: TArray<TGPTModel> read FData write FData;
    property &Object: string read FObject write FObject;
    destructor Destroy; override;
  end;

implementation

{ TGPTModels }

destructor TGPTModels.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TGPTModel }

destructor TGPTModel.Destroy;
begin
  for var Item in FPermission do
    Item.Free;
  inherited;
end;

end.


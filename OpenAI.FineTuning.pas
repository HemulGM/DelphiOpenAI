unit OpenAI.FineTuning;

interface

uses
  System.Generics.Collections, Rest.Json, System.Json, System.JSON.Types,
  OpenAI.API, System.SysUtils, OpenAI.API.Params;

type
  THyperparameters = class
  private
    FN_epochs: string;
    FLearning_rate_multiplier: Extended;
    FBatch_size: Int64;
  public
    /// <summary>
    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    /// "Auto" decides the optimal number of epochs based on the size of the dataset.
    /// If setting the number manually, we support any number between 1 and 50 epochs.
    /// </summary>
    property NEpochs: string read FN_epochs write FN_epochs;
    property BatchSize: Int64 read FBatch_size write FBatch_size;
    property LearningRateMultiplier: Extended read FLearning_rate_multiplier write FLearning_rate_multiplier;
  end;

  TFTError = class
  private
    FCode: string;
    FMessage: string;
    FParam: string;
  public
    /// <summary>
    /// A machine-readable error code.
    /// </summary>
    property Code: string read FCode write FCode;
    /// <summary>
    /// A human-readable error message.
    /// </summary>
    property Message: string read FMessage write FMessage;
    /// <summary>
    /// The parameter that was invalid, usually training_file or validation_file.
    /// This field will be null if the failure was not parameter-specific.
    /// </summary>
    property Param: string read FParam write FParam;
  end;

  TFTMetrics = class
  private
    [JsonNameAttribute('step')]
    FStep: Extended;
    [JsonNameAttribute('train_loss')]
    FTrainLoss: Extended;
    [JsonNameAttribute('train_mean_token_accuracy')]
    FTrainMeanTokenAccuracy: Extended;
    [JsonNameAttribute('valid_loss')]
    FValidLoss: Extended;
    [JsonNameAttribute('valid_mean_token_accuracy')]
    FValidMeanTokenAccuracy: Extended;
    [JsonNameAttribute('full_valid_loss')]
    FFullValidLoss: Extended;
    [JsonNameAttribute('full_valid_mean_token_accuracy')]
    FFullValidMeanTokenAccuracy: Extended;
  public
    property Step: Extended read FStep write FStep;
    property TrainLoss: Extended read FTrainLoss write FTrainLoss;
    property TrainMeanTokenAccuracy: Extended read FTrainMeanTokenAccuracy write FTrainMeanTokenAccuracy;
    property ValidLoss: Extended read FValidLoss write FValidLoss;
    property ValidMeanTokenAccuracy: Extended read FValidMeanTokenAccuracy write FValidMeanTokenAccuracy;
    property FullValidLoss: Extended read FFullValidLoss write FFullValidLoss;
    property FullValidMeanTokenAccuracy: Extended read FFullValidMeanTokenAccuracy write FFullValidMeanTokenAccuracy;
  end;

  TFTCheckPoint = class
  private
    [JsonNameAttribute('object')]
    FObject: string;
    [JsonNameAttribute('id')]
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('fine_tuned_model_checkpoint')]
    FFineTunedModelCheckpoint: string;
    [JsonNameAttribute('fine_tuning_job_id')]
    FFineTuningJobId: string;
    [JsonNameAttribute('metrics')]
    FMetrics: TFTMetrics;
    [JsonNameAttribute('step_number')]
    FStepNumber: Int64;
  public
    /// <summary>
    /// The object type, which is always "fine_tuning.job.checkpoint".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The checkpoint identifier, which can be referenced in the API endpoints.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The Unix timestamp (in seconds) for when the checkpoint was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// The name of the fine-tuned checkpoint model that is created.
    /// </summary>
    property FineTunedModelCheckpoint: string read FFineTunedModelCheckpoint write FFineTunedModelCheckpoint;
    /// <summary>
    /// The name of the fine-tuning job that this checkpoint was created from.
    /// </summary>
    property FineTuningJobId: string read FFineTuningJobId write FFineTuningJobId;
    /// <summary>
    /// Metrics at the step number during the fine-tuning job.
    /// </summary>
    property Metrics: TFTMetrics read FMetrics write FMetrics;
    /// <summary>
    /// The step number that the checkpoint was created at.
    /// </summary>
    property StepNumber: Int64 read FStepNumber write FStepNumber;
    destructor Destroy; override;
  end;

  TFTCheckPoints = class
  private
    FObject: string;
    FData: TArray<TFTCheckPoint>;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TFTCheckPoint> read FData write FData;
    destructor Destroy; override;
  end;

  TFTWandb = class
  private
    FName: string;
    FProject: string;
    FTags: TArray<string>;
    FEntity: string;
  public
    /// <summary>
    /// The name of the project that the new run will be created under.
    /// </summary>
    property Project: string read FProject write FProject;
    /// <summary>
    /// A display name to set for the run. If not set, we will use the Job ID as the name.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// The entity to use for the run. This allows you to set the team or username of the WandB user
    /// that you would like associated with the run. If not set, the default entity for the registered WandB API key is used.
    /// </summary>
    property Entity: string read FEntity write FEntity;
    /// <summary>
    /// A list of tags to be attached to the newly created run. These tags are passed through directly to WandB.
    /// Some default tags are generated by OpenAI: "openai/finetune", "openai/{base-model}", "openai/{ftjob-abcdef}".
    /// </summary>
    property Tags: TArray<string> read FTags write FTags;
  end;

  TFTIntegration = class
  private
    FType: string;
    FWandb: TFTWandb;
  public
    /// <summary>
    /// The type of the integration being enabled for the fine-tuning job
    /// </summary>
    property &Type: string read FType write FType;
    /// <summary>
    /// The settings for your integration with Weights and Biases.
    /// This payload specifies the project that metrics will be sent to.
    /// Optionally, you can set an explicit display name for your run, add tags to your run,
    /// and set a default entity (team, username, etc) to be associated with your run.
    /// </summary>
    property Wandb: TFTWandb read FWandb write FWandb;
    destructor Destroy; override;
  end;

  TFTIntegrations = TArray<TFTIntegration>;

  /// <summary>
  /// The fine-tuning job object
  /// </summary>
  TFineTuningJob = class
  private
    FCreated_at: Int64;
    FFine_tuned_model: string;
    FFinished_at: Int64;
    FHyperparameters: THyperparameters;
    FId: string;
    FModel: string;
    FObject: string;
    FOrganization_id: string;
    FResult_files: TArray<string>;
    FStatus: string;
    FTrained_tokens: Int64;
    FTraining_file: string;
    FValidation_file: string;
    FError: TFTError;
    FSeed: Int64;
    FEstimated_finish: Int64;
    FIntegrations: TFTIntegrations;
  public
    /// <summary>
    /// The Unix timestamp (in seconds) for when the fine-tuning job was created.
    /// </summary>
    property CreatedAt: Int64 read FCreated_at write FCreated_at;
    /// <summary>
    /// The name of the fine-tuned model that is being created.
    /// The value will be null if the fine-tuning job is still running.
    /// </summary>
    property FineTunedModel: string read FFine_tuned_model write FFine_tuned_model;
    /// <summary>
    /// The Unix timestamp (in seconds) for when the fine-tuning job was finished.
    /// The value will be null if the fine-tuning job is still running.
    /// </summary>
    property FinishedAt: Int64 read FFinished_at write FFinished_at;
    /// <summary>
    /// The hyperparameters used for the fine-tuning job. See the fine-tuning guide for more details.
    /// </summary>
    property Hyperparameters: THyperparameters read FHyperparameters write FHyperparameters;
    /// <summary>
    /// The object identifier, which can be referenced in the API endpoints.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The base model that is being fine-tuned.
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// The object type, which is always "fine_tuning.job".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The organization that owns the fine-tuning job.
    /// </summary>
    property OrganizationId: string read FOrganization_id write FOrganization_id;
    /// <summary>
    /// The compiled results file ID(s) for the fine-tuning job. You can retrieve the results with the
    /// </summary>
    property ResultFiles: TArray<string> read FResult_files write FResult_files;
    /// <summary>
    /// The current status of the fine-tuning job, which can be either created, pending, running, succeeded, failed, or cancelled.
    /// </summary>
    property Status: string read FStatus write FStatus;
    /// <summary>
    /// The total number of billable tokens processed by this fine-tuning job.
    /// The value will be null if the fine-tuning job is still running.
    /// </summary>
    property TrainedTokens: Int64 read FTrained_tokens write FTrained_tokens;
    /// <summary>
    /// The file ID used for training. You can retrieve the training data with the Files API.
    /// </summary>
    property TrainingFile: string read FTraining_file write FTraining_file;
    /// <summary>
    /// The file ID used for validation. You can retrieve the validation results with the Files API.
    /// </summary>
    property ValidationFile: string read FValidation_file write FValidation_file;
    /// <summary>
    /// For fine-tuning jobs that have failed, this will contain more information on the cause of the failure.
    /// </summary>
    property Error: TFTError read FError write FError;
    /// <summary>
    /// The seed used for the fine-tuning job.
    /// </summary>
    property Seed: Int64 read FSeed write FSeed;
    /// <summary>
    /// A list of integrations to enable for this fine-tuning job.
    /// </summary>
    property Integrations: TFTIntegrations read FIntegrations write FIntegrations;
    /// <summary>
    /// The Unix timestamp (in seconds) for when the fine-tuning job is estimated to finish.
    /// The value will be null if the fine-tuning job is not running.
    /// </summary>
    property EstimatedFinish: Int64 read FEstimated_finish write FEstimated_finish;
    destructor Destroy; override;
  end;

  TFineTiningEventData = class
  private
    FStep: Integer;
    FTrain_loss: Extended;
    FTrain_mean_token_accuracy: Extended;
  public
    property Step: Integer read FStep write FStep;
    property TrainLoss: Extended read FTrain_loss write FTrain_loss;
    property TrainMeanTokenAccuracy: Extended read FTrain_mean_token_accuracy write FTrain_mean_token_accuracy;
  end;

  TFineTuningEvent = class
  private
    FCreated_at: Int64;
    FData: TFineTiningEventData;
    FId: string;
    FLevel: string;
    FMessage: string;
    FObject: string;
    FType: string;
  public
    property CreatedAt: Int64 read FCreated_at write FCreated_at;
    property Data: TFineTiningEventData read FData write FData;
    property Id: string read FId write FId;
    /// <summary>
    /// info, warn
    /// </summary>
    property Level: string read FLevel write FLevel;
    property Message: string read FMessage write FMessage;
    property &Object: string read FObject write FObject;
    /// <summary>
    /// message, metrics
    /// </summary>
    property &Type: string read FType write FType;
    destructor Destroy; override;
  end;

  TFineTuningJobs = class
  private
    FObject: string;
    FData: TArray<TFineTuningJob>;
    FHas_more: Boolean;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TFineTuningJob> read FData write FData;
    property HasMore: Boolean read FHas_more write FHas_more;
    destructor Destroy; override;
  end;

  TFineTuningJobEvents = class
  private
    FObject: string;
    FData: TArray<TFineTuningEvent>;
    FHas_more: Boolean;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TFineTuningEvent> read FData write FData;
    property HasMore: Boolean read FHas_more write FHas_more;
    destructor Destroy; override;
  end;

  TFineTuningHyperParams = class(TJSONParam)
    /// <summary>
    /// Number of examples in each batch. A larger batch size means that model parameters are updated less frequently,
    /// but with lower variance.
    /// </summary>
    function BatchSize(const Value: Int64): TFineTuningHyperParams;
    /// <summary>
    /// Scaling factor for the learning rate. A smaller learning rate may be useful to avoid overfitting.
    /// </summary>
    function LearningRateMultiplier(const Value: Extended): TFineTuningHyperParams;
    /// <summary>
    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    /// </summary>
    function NEpochs(const Value: Int64): TFineTuningHyperParams;
  end;

  TFineTuningWandbParams = class(TJSONParam)
    /// <summary>
    /// Required
    /// The name of the project that the new run will be created under.
    /// </summary>
    function Project(const Value: string): TFineTuningWandbParams;
    /// <summary>
    /// Optional
    /// A display name to set for the run. If not set, we will use the Job ID as the name.
    /// </summary>
    function Name(const Value: string): TFineTuningWandbParams;
    /// <summary>
    /// Optional
    /// The entity to use for the run. This allows you to set the team or username of the WandB user
    /// that you would like associated with the run. If not set, the default entity for the registered WandB API key is used.
    /// </summary>
    function Entity(const Value: string): TFineTuningWandbParams;
    /// <summary>
    /// Optional
    /// A list of tags to be attached to the newly created run.
    /// These tags are passed through directly to WandB. Some default tags are generated by OpenAI:
    /// "openai/finetune", "openai/{base-model}", "openai/{ftjob-abcdef}".
    /// </summary>
    function Tags(const Value: TArray<string>): TFineTuningWandbParams;
  end;

  TFineTuningIntegrationParams = class(TJSONParam)
    /// <summary>
    /// The type of integration to enable. Currently, only "wandb" (Weights and Biases) is supported.
    /// </summary>
    function  &Type(const Value: string): TFineTuningIntegrationParams;
    /// <summary>
    /// The settings for your integration with Weights and Biases.
    /// This payload specifies the project that metrics will be sent to.
    /// Optionally, you can set an explicit display name for your run, add tags to your run,
    /// and set a default entity (team, username, etc) to be associated with your run.
    /// </summary>
    function Wandb(const Value: TFineTuningWandbParams): TFineTuningIntegrationParams;
  end;

  TFineTuningCreateParams = class(TJSONParam)
    /// <summary>
    /// Required.
    /// The ID of an uploaded file that contains training data.
    /// Your dataset must be formatted as a JSONL file. Additionally, you must upload your file with the purpose fine-tune.
    /// </summary>
    function TrainingFile(const Value: string): TFineTuningCreateParams;
    /// <summary>
    /// The ID of an uploaded file that contains validation data.
    /// If you provide this file, the data is used to generate validation metrics periodically during fine-tuning.
    /// These metrics can be viewed in the fine-tuning results file.
    /// The same data should not be present in both train and validation files.
    /// Your dataset must be formatted as a JSONL file. You must upload your file with the purpose fine-tune.
    /// </summary>
    function ValidationFile(const Value: string): TFineTuningCreateParams;
    /// <summary>
    /// Required.
    /// The name of the model to fine-tune. You can select one of the supported models.
    /// </summary>
    function Model(const Value: string): TFineTuningCreateParams;
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object.
    /// This can be useful for storing additional information about the object in a structured format,
    /// and querying for objects via API or the dashboard.
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
    /// </summary>
    function Metadata(const Value: TJSONValue): TFineTuningCreateParams;
    /// <summary>
    /// The hyperparameters used for the fine-tuning job. This value is now deprecated in favor of method, and should be passed in under the method parameter.
    /// </summary>
    function Hyperparameters(const Value: TFineTuningHyperParams): TFineTuningCreateParams; deprecated;
    /// <summary>
    /// A string of up to 64 characters that will be added to your fine-tuned model name.
    /// For example, a suffix of "custom-model-name" would produce a model name
    /// like ft:gpt-4o-mini:openai:custom-model-name:7p4lURel.
    /// </summary>
    function Suffix(const Value: string): TFineTuningCreateParams;
    /// <summary>
    /// A list of integrations to enable for your fine-tuning job.
    /// </summary>
    function Integrations(const Value: TFineTuningIntegrationParams): TFineTuningCreateParams;
    /// <summary>
    /// The seed controls the reproducibility of the job. Passing in the same seed and job parameters should produce
    /// the same results, but may differ in rare cases. If a seed is not specified, one will be generated for you.
    /// </summary>
    function Seed(const Value: Int64): TFineTuningCreateParams;
  end;

  TFineTuningListParams = class(TJSONParam)
    /// <summary>
    /// Identifier for the last job from the previous pagination request.
    /// </summary>
    function After(const Value: string): TFineTuningListParams;
    /// <summary>
    /// Number of fine-tuning jobs to retrieve. Defaults to 20.
    /// </summary>
    function Limit(const Value: Integer): TFineTuningListParams;
  end;

  TFineTuningRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    function Create(ParamProc: TProc<TFineTuningCreateParams>): TFineTuningJob;
    /// <summary>
    /// List your organization's fine-tuning jobs
    /// </summary>
    function List(ParamProc: TProc<TFineTuningListParams> = nil): TFineTuningJobs;
    /// <summary>
    /// Get info about a fine-tuning job.
    /// </summary>
    function Retrieve(const FineTuningJobId: string): TFineTuningJob;
    /// <summary>
    /// Immediately cancel a fine-tune job.
    /// </summary>
    function Cancel(const FineTuningJobId: string): TFineTuningJob;
    /// <summary>
    /// Get status updates for a fine-tuning job.
    /// </summary>
    function ListEvents(const FineTuningJobId: string; ParamProc: TProc<TFineTuningListParams> = nil): TFineTuningJobEvents;
    /// <summary>
    /// List checkpoints for a fine-tuning job.
    /// </summary>
    function ListCheckpoints(const FineTuningJobId: string; ParamProc: TProc<TFineTuningListParams> = nil): TFTCheckPoints;
  end;

implementation

{ TFineTuningJob }

destructor TFineTuningJob.Destroy;
var
  Item: TFTIntegration;
begin
  FHyperparameters.Free;
  FError.Free;
  for Item in FIntegrations do
    Item.Free;
  inherited;
end;

{ TFineTuningCreateParams }

function TFineTuningCreateParams.Hyperparameters(const Value: TFineTuningHyperParams): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('hyperparameters', Value));
end;

function TFineTuningCreateParams.Integrations(const Value: TFineTuningIntegrationParams): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('integrations', Value));
end;

function TFineTuningCreateParams.Metadata(const Value: TJSONValue): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('metadata', Value));
end;

function TFineTuningCreateParams.Model(const Value: string): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('model', Value));
end;

function TFineTuningCreateParams.Seed(const Value: Int64): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('seed', Value));
end;

function TFineTuningCreateParams.Suffix(const Value: string): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('suffix', Value));
end;

function TFineTuningCreateParams.TrainingFile(const Value: string): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('training_file', Value));
end;

function TFineTuningCreateParams.ValidationFile(const Value: string): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('validation_file', Value));
end;

{ TFineTuningRoute }

function TFineTuningRoute.Cancel(const FineTuningJobId: string): TFineTuningJob;
begin
  Result := API.Post<TFineTuningJob>('fine_tuning/jobs/' + FineTuningJobId + '/cancel');
end;

function TFineTuningRoute.Create(ParamProc: TProc<TFineTuningCreateParams>): TFineTuningJob;
begin
  Result := API.Post<TFineTuningJob, TFineTuningCreateParams>('fine_tuning/jobs', ParamProc);
end;

function TFineTuningRoute.List(ParamProc: TProc<TFineTuningListParams>): TFineTuningJobs;
begin
  Result := API.Get<TFineTuningJobs, TFineTuningListParams>('fine_tuning/jobs', ParamProc);
end;

function TFineTuningRoute.ListCheckpoints(const FineTuningJobId: string; ParamProc: TProc<TFineTuningListParams>): TFTCheckPoints;
begin
  Result := API.Get<TFTCheckPoints, TFineTuningListParams>('fine_tuning/jobs/' + FineTuningJobId + '/checkpoints', ParamProc);
end;

function TFineTuningRoute.ListEvents(const FineTuningJobId: string; ParamProc: TProc<TFineTuningListParams>): TFineTuningJobEvents;
begin
  Result := API.Get<TFineTuningJobEvents, TFineTuningListParams>('fine_tuning/jobs/' + FineTuningJobId + '/events', ParamProc);
end;

function TFineTuningRoute.Retrieve(const FineTuningJobId: string): TFineTuningJob;
begin
  Result := API.Get<TFineTuningJob>('fine_tuning/jobs/' + FineTuningJobId);
end;

{ TFineTuningJobs }

destructor TFineTuningJobs.Destroy;
var
  Item: TFineTuningJob;
begin
  for Item in FData do
    Item.Free;
  inherited;
end;

{ TFineTuningListParams }

function TFineTuningListParams.After(const Value: string): TFineTuningListParams;
begin
  Result := TFineTuningListParams(Add('after', Value));
end;

function TFineTuningListParams.Limit(const Value: Integer): TFineTuningListParams;
begin
  Result := TFineTuningListParams(Add('limit', Value));
end;

{ TFineTuningEvent }

destructor TFineTuningEvent.Destroy;
begin
  FData.Free;
  inherited;
end;

{ TFineTuningJobEvents }

destructor TFineTuningJobEvents.Destroy;
var
  Item: TFineTuningEvent;
begin
  for Item in FData do
    Item.Free;
  inherited;
end;

{ TFineTuningHyperParams }

function TFineTuningHyperParams.BatchSize(const Value: Int64): TFineTuningHyperParams;
begin
  Result := TFineTuningHyperParams(Add('batch_size', Value));
end;

function TFineTuningHyperParams.LearningRateMultiplier(const Value: Extended): TFineTuningHyperParams;
begin
  Result := TFineTuningHyperParams(Add('learning_rate_multiplier', Value));
end;

function TFineTuningHyperParams.NEpochs(const Value: Int64): TFineTuningHyperParams;
begin
  Result := TFineTuningHyperParams(Add('n_epochs', Value));
end;

{ TFineTuningIntegrationParams }

function TFineTuningIntegrationParams.&Type(const Value: string): TFineTuningIntegrationParams;
begin
  Result := TFineTuningIntegrationParams(Add('type', Value));
end;

function TFineTuningIntegrationParams.Wandb(const Value: TFineTuningWandbParams): TFineTuningIntegrationParams;
begin
  Result := TFineTuningIntegrationParams(Add('wandb', Value));
end;

{ TFineTuningWandbParams }

function TFineTuningWandbParams.Entity(const Value: string): TFineTuningWandbParams;
begin
  Result := TFineTuningWandbParams(Add('entity', Value));
end;

function TFineTuningWandbParams.Name(const Value: string): TFineTuningWandbParams;
begin
  Result := TFineTuningWandbParams(Add('name', Value));
end;

function TFineTuningWandbParams.Project(const Value: string): TFineTuningWandbParams;
begin
  Result := TFineTuningWandbParams(Add('project', Value));
end;

function TFineTuningWandbParams.Tags(const Value: TArray<string>): TFineTuningWandbParams;
begin
  Result := TFineTuningWandbParams(Add('tags', Value));
end;

{ TFTIntegration }

destructor TFTIntegration.Destroy;
begin
  FWandb.Free;
  inherited;
end;

{ TFTCheckPoint }

destructor TFTCheckPoint.Destroy;
begin
  FMetrics.Free;
  inherited;
end;

{ TFTCheckPoints }

destructor TFTCheckPoints.Destroy;
var
  Item: TFTCheckPoint;
begin
  for Item in FData do
    Item.Free;
  inherited;
end;

end.


unit OpenAI.FineTuning;

interface

uses
  System.Generics.Collections, Rest.Json, OpenAI.API, System.SysUtils,
  OpenAI.API.Params;

type
  THyperparameters = class
  private
    FN_epochs: string;
  public
    /// <summary>
    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    /// "Auto" decides the optimal number of epochs based on the size of the dataset.
    /// If setting the number manually, we support any number between 1 and 50 epochs.
    /// </summary>
    property NEpochs: string read FN_epochs write FN_epochs;
  end;

  TFTError = class
    // не известно пока
  end;

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
    /// The hyperparameters used for the fine-tuning job.
    /// </summary>
    /// <param name="NEpochs">
    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    /// </param>
    function Hyperparameters(const NEpochs: Integer): TFineTuningCreateParams;
    /// <summary>
    /// A string of up to 18 characters that will be added to your fine-tuned model name.
    /// For example, a suffix of "custom-model-name" would produce a model name like ft:gpt-3.5-turbo:openai:custom-model-name:7p4lURel.
    /// </summary>
    function Suffix(const Value: string): TFineTuningCreateParams;
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
  end;

implementation

uses
  System.JSON;

{ TFineTuningJob }

destructor TFineTuningJob.Destroy;
begin
  FHyperparameters.Free;
  FError.Free;
  inherited;
end;

{ TFineTuningCreateParams }

function TFineTuningCreateParams.Hyperparameters(const NEpochs: Integer): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('hyperparameters', TJSONObject.Create(TJSONPair.Create('n_epochs', TJSONNumber.Create(NEpochs)))));
end;

function TFineTuningCreateParams.Model(const Value: string): TFineTuningCreateParams;
begin
  Result := TFineTuningCreateParams(Add('model', Value));
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

end.


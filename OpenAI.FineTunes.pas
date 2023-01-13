unit OpenAI.FineTunes;

interface

uses
  System.SysUtils, OpenAI.API, OpenAI.API.Params, OpenAI.Files;

type
  TFineTuneCreateParams = class(TJSONParam)
    /// <summary>
    /// The ID of an uploaded file that contains training data.
    /// See upload file for how to upload a file.
    /// Your dataset must be formatted as a JSONL file, where each training example is a
    /// JSON object with the keys "prompt" and "completion".
    /// Additionally, you must upload your file with the purpose fine-tune.
    /// See the fine-tuning guide for more details.
    /// </summary>
    function TrainingFile(const Value: string): TFineTuneCreateParams;
    /// <summary>
    /// The ID of an uploaded file that contains validation data.
    /// If you provide this file, the data is used to generate validation metrics
    /// periodically during fine-tuning. These metrics can be viewed in the fine-tuning results file.
    /// Your train and validation data should be mutually exclusive.
    /// Your dataset must be formatted as a JSONL file, where each validation example is a
    /// JSON object with the keys "prompt" and "completion".
    /// Additionally, you must upload your file with the purpose fine-tune.
    /// See the fine-tuning guide for more details.
    /// </summary>
    function ValidationFile(const Value: string): TFineTuneCreateParams;
    /// <summary>
    /// The name of the base model to fine-tune. You can select one of "ada", "babbage", "curie", "davinci", or a
    /// fine-tuned model created after 2022-04-21. To learn more about these models, see the Models documentation.
    /// </summary>
    function Model(const Value: string): TFineTuneCreateParams;
    /// <summary>
    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    /// </summary>
    function nEpochs(const Value: Integer = 4): TFineTuneCreateParams;
    /// <summary>
    /// The batch size to use for training. The batch size is the number of training examples used to train a
    /// single forward and backward pass.
    /// By default, the batch size will be dynamically configured to be ~0.2% of the number of examples in the
    /// training set, capped at 256 - in general, we've found that larger batch sizes tend to work better for larger datasets.
    /// </summary>
    function BatchSize(const Value: Integer): TFineTuneCreateParams;
    /// <summary>
    /// The learning rate multiplier to use for training. The fine-tuning learning rate is the original
    /// learning rate used for pretraining multiplied by this value.
    /// By default, the learning rate multiplier is the 0.05, 0.1, or 0.2 depending on
    /// final batch_size (larger learning rates tend to perform better with larger batch sizes).
    /// We recommend experimenting with values in the range 0.02 to 0.2 to see what produces the best results.
    /// </summary>
    function LearningRateMultiplier(const Value: Extended): TFineTuneCreateParams;
    /// <summary>
    /// The weight to use for loss on the prompt tokens. This controls how much the model tries to
    /// learn to generate the prompt (as compared to the completion which always has a weight of 1.0),
    /// and can add a stabilizing effect to training when completions are short.
    /// If prompts are extremely long (relative to completions), it may make sense to reduce this weight so as
    /// to avoid over-prioritizing learning the prompt.
    /// </summary>
    function PromptLossWeight(const Value: Extended = 0.01): TFineTuneCreateParams;
    /// <summary>
    /// If set, we calculate classification-specific metrics such as accuracy and F-1 score using the
    /// validation set at the end of every epoch. These metrics can be viewed in the results file.
    /// In order to compute classification metrics, you must provide a validation_file.
    /// Additionally, you must specify classification_n_classes for multiclass classification or
    /// classification_positive_class for binary classification.
    /// </summary>
    function ComputeClassificationMetrics(const Value: Boolean = True): TFineTuneCreateParams;
    /// <summary>
    /// The number of classes in a classification task.
    /// This parameter is required for multiclass classification.
    /// </summary>
    function ClassificationNClasses(const Value: Integer): TFineTuneCreateParams;
    /// <summary>
    /// The positive class in binary classification.
    /// This parameter is needed to generate precision, recall, and F1 metrics when doing binary classification.
    /// </summary>
    function ClassificationPositiveClass(const Value: string): TFineTuneCreateParams;
    /// <summary>
    /// If this is provided, we calculate F-beta scores at the specified beta values.
    /// The F-beta score is a generalization of F-1 score. This is only used for binary classification.
    /// With a beta of 1 (i.e. the F-1 score), precision and recall are given the same weight.
    /// A larger beta score puts more weight on recall and less on precision.
    /// A smaller beta score puts more weight on precision and less on recall.
    /// </summary>
    function ClassificationBetas(const Value: string): TFineTuneCreateParams;
    /// <summary>
    /// A string of up to 40 characters that will be added to your fine-tuned model name.
    /// For example, a suffix of "custom-model-name" would produce a model name like
    /// ada:ft-your-org:custom-model-name-2022-02-15-04-21-04.
    /// </summary>
    function Suffix(const Value: string): TFineTuneCreateParams;
  end;

  THyperparams = class
  private
    FBatch_size: Extended;
    FLearning_rate_multiplier: Extended;
    FN_epochs: Extended;
    FPrompt_loss_weight: Extended;
  public
    property BatchSize: Extended read FBatch_size write FBatch_size;
    property LearningRateMultiplier: Extended read FLearning_rate_multiplier write FLearning_rate_multiplier;
    property nEpochs: Extended read FN_epochs write FN_epochs;
    property PromptLossWeight: Extended read FPrompt_loss_weight write FPrompt_loss_weight;
  end;

  TFineTuneEvent = class
  private
    FCreated_at: Int64;
    FLevel: string;
    FMessage: string;
    FObject: string;
  public
    property CreatedAt: Int64 read FCreated_at write FCreated_at;
    property Level: string read FLevel write FLevel;
    property Message: string read FMessage write FMessage;
    property &Object: string read FObject write FObject;
  end;

  TFineTuneEvents = class
  private
    FObject: string;
    FData: TArray<TFineTuneEvent>;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TFineTuneEvent> read FData write FData;
    destructor Destroy; override;
  end;

  TFineTune = class
  private
    FCreated_at: Int64;
    FEvents: TArray<TFineTuneEvent>;
    FHyperparams: THyperparams;
    FId: string;
    FModel: string;
    FObject: string;
    FOrganization_id: string;
    FResult_files: TArray<TFile>;
    FStatus: string;
    FTraining_files: TArray<TFile>;
    FUpdated_at: Int64;
    FValidation_files: TArray<TFile>;
    FFine_tuned_model: string;
  public
    property CreatedAt: Int64 read FCreated_at write FCreated_at;
    property Events: TArray<TFineTuneEvent> read FEvents write FEvents;
    property Hyperparams: THyperparams read FHyperparams write FHyperparams;
    property FineTunedModel: string read FFine_tuned_model write FFine_tuned_model;
    property Id: string read FId write FId;
    property Model: string read FModel write FModel;
    property &Object: string read FObject write FObject;
    property OrganizationId: string read FOrganization_id write FOrganization_id;
    property ResultFiles: TArray<TFile> read FResult_files write FResult_files;
    /// <summary>
    /// succeeded, cancelled, pending
    /// </summary>
    property Status: string read FStatus write FStatus;
    property TrainingFiles: TArray<TFile> read FTraining_files write FTraining_files;
    property UpdatedAt: Int64 read FUpdated_at write FUpdated_at;
    property ValidationFiles: TArray<TFile> read FValidation_files write FValidation_files;
    destructor Destroy; override;
  end;

  TFineTunes = class
  private
    FObject: string;
    FData: TArray<TFineTune>;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TFineTune> read FData write FData;
    destructor Destroy; override;
  end;

  TFineTunesRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Creates a job that fine-tunes a specified model from a given dataset.
    /// Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
    /// </summary>
    function Create(ParamProc: TProc<TFineTuneCreateParams>): TFineTune;
    /// <summary>
    /// List your organization's fine-tuning jobs
    /// </summary>
    function List: TFineTunes;
    /// <summary>
    /// Gets info about the fine-tune job.
    /// </summary>
    function Retrieve(const FineTuneId: string): TFineTune;
    /// <summary>
    /// Immediately cancel a fine-tune job.
    /// </summary>
    function Cancel(const FineTuneId: string): TFineTune;
    /// <summary>
    /// Get fine-grained status updates for a fine-tune job.
    /// </summary>
    /// <param name="Stream">Whether to stream events for the fine-tune job.
    /// If set to true, events will be sent as data-only server-sent events as they become available.
    /// The stream will terminate with a data: [DONE] message when the job is finished (succeeded, cancelled, or failed).
    /// If set to false, only events generated so far will be returned.
    /// </param>
    function ListEvents(const FineTuneId: string; Stream: Boolean = False): TFineTuneEvents;
    /// <summary>
    /// Delete a fine-tuned model. You must have the Owner role in your organization.
    /// </summary>
    function Delete(const Model: string): TDeletedInfo;
  end;

implementation

uses
  System.StrUtils;

{ TFineTunesRoute }

function TFineTunesRoute.Cancel(const FineTuneId: string): TFineTune;
begin
  Result := API.Post<TFineTune>('fine-tunes/' + FineTuneId + '/cancel');
end;

function TFineTunesRoute.Create(ParamProc: TProc<TFineTuneCreateParams>): TFineTune;
begin
  Result := API.Post<TFineTune, TFineTuneCreateParams>('fine-tunes', ParamProc);
end;

function TFineTunesRoute.Delete(const Model: string): TDeletedInfo;
begin
  Result := API.Delete<TDeletedInfo>('models/' + Model);
end;

function TFineTunesRoute.List: TFineTunes;
begin
  Result := API.Get<TFineTunes>('fine-tunes');
end;

function TFineTunesRoute.ListEvents(const FineTuneId: string; Stream: Boolean): TFineTuneEvents;
begin
  Result := API.Get<TFineTuneEvents>('fine-tunes/' + FineTuneId + '/events' + IfThen(Stream, '?stream=true'));
end;

function TFineTunesRoute.Retrieve(const FineTuneId: string): TFineTune;
begin
  Result := API.Get<TFineTune>('fine-tunes/' + FineTuneId);
end;

{ TFineTune }

destructor TFineTune.Destroy;
begin
  if Assigned(FHyperparams) then
    FHyperparams.Free;
  for var Item in FEvents do
    if Assigned(Item) then
      Item.Free;
  for var Item in FResult_files do
    if Assigned(Item) then
      Item.Free;
  for var Item in FTraining_files do
    if Assigned(Item) then
      Item.Free;
  for var Item in FValidation_files do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TFineTunes }

destructor TFineTunes.Destroy;
begin
  for var Item in FData do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TFineTuneEvents }

destructor TFineTuneEvents.Destroy;
begin
  for var Item in FData do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TFineTuneCreateParams }

function TFineTuneCreateParams.BatchSize(const Value: Integer): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('batch_size', Value));
end;

function TFineTuneCreateParams.ClassificationBetas(const Value: string): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('classification_betas', Value));
end;

function TFineTuneCreateParams.ClassificationNClasses(const Value: Integer): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('classification_n_classes', Value));
end;

function TFineTuneCreateParams.ClassificationPositiveClass(const Value: string): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('classification_positive_class', Value));
end;

function TFineTuneCreateParams.ComputeClassificationMetrics(const Value: Boolean): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('compute_classification_metrics', Value));
end;

function TFineTuneCreateParams.LearningRateMultiplier(const Value: Extended): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('learning_rate_multiplier', Value));
end;

function TFineTuneCreateParams.Model(const Value: string): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('model', Value));
end;

function TFineTuneCreateParams.nEpochs(const Value: Integer): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('n_epochs', Value));
end;

function TFineTuneCreateParams.PromptLossWeight(const Value: Extended): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('prompt_loss_weight', Value));
end;

function TFineTuneCreateParams.Suffix(const Value: string): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('suffix', Value));
end;

function TFineTuneCreateParams.TrainingFile(const Value: string): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('training_file', Value));
end;

function TFineTuneCreateParams.ValidationFile(const Value: string): TFineTuneCreateParams;
begin
  Result := TFineTuneCreateParams(Add('validation_file', Value));
end;

end.


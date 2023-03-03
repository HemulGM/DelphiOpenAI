unit OpenAI.Moderations;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API, Rest.Json.Types;

type
  TModerationsParams = class(TJSONParam)
    /// <summary>
    /// Two content moderations models are available: "text-moderation-stable" and "text-moderation-latest".
    /// The default is text-moderation-latest which will be automatically upgraded over time.
    /// This ensures you are always using our most accurate model. If you use text-moderation-stable,
    /// we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be
    /// slightly lower than for text-moderation-latest.
    /// </summary>
    function Model(const Value: string = 'text-moderation-latest'): TModerationsParams;
    /// <summary>
    /// The input text to classify
    /// </summary>
    function Input(const Value: string): TModerationsParams; overload;
    /// <summary>
    /// The input text to classify
    /// </summary>
    function Input(const Value: TArray<string>): TModerationsParams; overload;
    constructor Create; reintroduce;
  end;

  TCategoryScores = class
  private
    FHate: Extended;
    [JSONName('hate/threatening')]
    FHatethreatening: Extended;
    [JSONName('self-harm')]
    FSelfharm: Extended;
    FSexual: Extended;
    [JSONName('sexual/minors')]
    FSexualminors: Extended;
    FViolence: Extended;
    [JSONName('violence/graphic')]
    FViolencegraphic: Extended;
  public
    property Hate: Extended read FHate write FHate;
    property HateOrThreatening: Extended read FHatethreatening write FHatethreatening;
    property SelfHarm: Extended read FSelfharm write FSelfharm;
    property Sexual: Extended read FSexual write FSexual;
    property SexualOrMinors: Extended read FSexualminors write FSexualminors;
    property Violence: Extended read FViolence write FViolence;
    property ViolenceOrGraphic: Extended read FViolencegraphic write FViolencegraphic;
  end;

  TCategories = class
  private
    FHate: Boolean;
    [JSONName('hate/threatening')]
    FHatethreatening: Boolean;
    [JSONName('self-harm')]
    FSelfharm: Boolean;
    FSexual: Boolean;
    [JSONName('sexual/minors')]
    FSexualminors: Boolean;
    FViolence: Boolean;
    [JSONName('violence/graphic')]
    FViolencegraphic: Boolean;
  public
    property Hate: Boolean read FHate write FHate;
    property HateOrThreatening: Boolean read FHatethreatening write FHatethreatening;
    property SelfHarm: Boolean read FSelfharm write FSelfharm;
    property Sexual: Boolean read FSexual write FSexual;
    property SexualOrMinors: Boolean read FSexualminors write FSexualminors;
    property Violence: Boolean read FViolence write FViolence;
    property ViolenceOrGraphic: Boolean read FViolencegraphic write FViolencegraphic;
  end;

  TResult = class
  private
    FCategories: TCategories;
    FCategory_scores: TCategoryScores;
    FFlagged: Boolean;
  public
    property Categories: TCategories read FCategories write FCategories;
    property CategoryScores: TCategoryScores read FCategory_scores write FCategory_scores;
    property Flagged: Boolean read FFlagged write FFlagged;
    destructor Destroy; override;
  end;

  TModerations = class
  private
    FId: string;
    FModel: string;
    FResults: TArray<TResult>;
  public
    property Id: string read FId write FId;
    property Model: string read FModel write FModel;
    property Results: TArray<TResult> read FResults write FResults;
  end;

  TModerationsRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Classifies if text violates OpenAI's Content Policy
    /// </summary>
    function Create(ParamProc: TProc<TModerationsParams>): TModerations;
  end;

implementation

{ TModerationsRoute }

function TModerationsRoute.Create(ParamProc: TProc<TModerationsParams>): TModerations;
begin
  Result := API.Post<TModerations, TModerationsParams>('moderations', ParamProc);
end;

{ TModerationsParams }

constructor TModerationsParams.Create;
begin
  inherited;
  Model();
end;

function TModerationsParams.Input(const Value: TArray<string>): TModerationsParams;
begin
  Result := TModerationsParams(Add('input', Value));
end;

function TModerationsParams.Model(const Value: string): TModerationsParams;
begin
  Result := TModerationsParams(Add('model', Value));
end;

function TModerationsParams.Input(const Value: string): TModerationsParams;
begin
  Result := TModerationsParams(Add('input', Value));
end;

{ TResult }

destructor TResult.Destroy;
begin
  if Assigned(FCategories) then
    FCategories.Free;
  if Assigned(FCategory_scores) then
    FCategory_scores.Free;
  inherited;
end;

end.


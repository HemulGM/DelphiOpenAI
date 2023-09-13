unit OpenAI.Moderations;

interface

uses
  System.SysUtils, OpenAI.API.Params, OpenAI.API, Rest.Json.Types;

type
  TModerationsParams = class(TJSONParam)
    /// <summary>
    /// The input text to classify
    /// </summary>
    function Input(const Value: string): TModerationsParams; overload;
    /// <summary>
    /// The input text to classify
    /// </summary>
    function Input(const Value: TArray<string>): TModerationsParams; overload;
    /// <summary>
    /// Two content moderations models are available: "text-moderation-stable" and "text-moderation-latest".
    /// The default is text-moderation-latest which will be automatically upgraded over time.
    /// This ensures you are always using our most accurate model. If you use text-moderation-stable,
    /// we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be
    /// slightly lower than for text-moderation-latest.
    /// </summary>
    function Model(const Value: string = 'text-moderation-latest'): TModerationsParams;
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
    FHarassment: Extended;
    [JSONName('harassment/threatening')]
    FHarassmentthreatening: Extended;
    [JSONName('self-harm/intent')]
    FSelfharmintent: Extended;
    [JSONName('self-harm/instructions')]
    FSelfharminstructions: Extended;
  public
    /// <summary>
    /// Content that expresses, incites, or promotes hate based on race, gender, ethnicity, religion, nationality,
    /// sexual orientation, disability status, or caste. Hateful content aimed at non-protected groups (e.g., chess players)
    /// is harrassment.
    /// </summary>
    property Hate: Extended read FHate write FHate;
    /// <summary>
    /// Hateful content that also includes violence or serious harm towards the targeted group based on race,
    /// gender, ethnicity, religion, nationality, sexual orientation, disability status, or caste.
    /// </summary>
    property HateOrThreatening: Extended read FHatethreatening write FHatethreatening;
    /// <summary>
    /// Content that expresses, incites, or promotes harassing language towards any target.
    /// </summary>
    property Harassment: Extended read FHarassment write FHarassment;
    /// <summary>
    /// Harassment content that also includes violence or serious harm towards any target.
    /// </summary>
    property HarassmentOrThreatening: Extended read FHarassmentthreatening write FHarassmentthreatening;
    /// <summary>
    /// Content that promotes, encourages, or depicts acts of self-harm, such as suicide, cutting, and eating disorders.
    /// </summary>
    property SelfHarm: Extended read FSelfharm write FSelfharm;
    /// <summary>
    /// Content where the speaker expresses that they are engaging or intend to engage in acts of self-harm,
    /// such as suicide, cutting, and eating disorders.
    /// </summary>
    property SelfHarmOrIntent: Extended read FSelfharmintent write FSelfharmintent;
    /// <summary>
    /// Content that encourages performing acts of self-harm, such as suicide, cutting, and eating disorders,
    /// or that gives instructions or advice on how to commit such acts.
    /// </summary>
    property SelfHarmOrInstructions: Extended read FSelfharminstructions write FSelfharminstructions;
    /// <summary>
    /// Content meant to arouse sexual excitement, such as the description of sexual activity,
    /// or that promotes sexual services (excluding sex education and wellness).
    /// </summary>
    property Sexual: Extended read FSexual write FSexual;
    /// <summary>
    /// Sexual content that includes an individual who is under 18 years old.
    /// </summary>
    property SexualOrMinors: Extended read FSexualminors write FSexualminors;
    /// <summary>
    /// Content that depicts death, violence, or physical injury.
    /// </summary>
    property Violence: Extended read FViolence write FViolence;
    /// <summary>
    /// Content that depicts death, violence, or physical injury in graphic detail.
    /// </summary>
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
    FHarassment: Boolean;
    [JSONName('harassment/threatening')]
    FHarassmentthreatening: Boolean;
    [JSONName('self-harm/intent')]
    FSelfharmintent: Boolean;
    [JSONName('self-harm/instructions')]
    FSelfharminstructions: Boolean;
  public
    /// <summary>
    /// Content that expresses, incites, or promotes hate based on race, gender, ethnicity, religion, nationality,
    /// sexual orientation, disability status, or caste. Hateful content aimed at non-protected groups (e.g., chess players)
    /// is harrassment.
    /// </summary>
    property Hate: Boolean read FHate write FHate;
    /// <summary>
    /// Hateful content that also includes violence or serious harm towards the targeted group based on race,
    /// gender, ethnicity, religion, nationality, sexual orientation, disability status, or caste.
    /// </summary>
    property HateOrThreatening: Boolean read FHatethreatening write FHatethreatening;
    /// <summary>
    /// Content that expresses, incites, or promotes harassing language towards any target.
    /// </summary>
    property Harassment: Boolean read FHarassment write FHarassment;
    /// <summary>
    /// Harassment content that also includes violence or serious harm towards any target.
    /// </summary>
    property HarassmentOrThreatening: Boolean read FHarassmentthreatening write FHarassmentthreatening;
    /// <summary>
    /// Content that promotes, encourages, or depicts acts of self-harm, such as suicide, cutting, and eating disorders.
    /// </summary>
    property SelfHarm: Boolean read FSelfharm write FSelfharm;
    /// <summary>
    /// Content where the speaker expresses that they are engaging or intend to engage in acts of self-harm,
    /// such as suicide, cutting, and eating disorders.
    /// </summary>
    property SelfHarmOrIntent: Boolean read FSelfharmintent write FSelfharmintent;
    /// <summary>
    /// Content that encourages performing acts of self-harm, such as suicide, cutting, and eating disorders,
    /// or that gives instructions or advice on how to commit such acts.
    /// </summary>
    property SelfHarmOrInstructions: Boolean read FSelfharminstructions write FSelfharminstructions;
    /// <summary>
    /// Content meant to arouse sexual excitement, such as the description of sexual activity,
    /// or that promotes sexual services (excluding sex education and wellness).
    /// </summary>
    property Sexual: Boolean read FSexual write FSexual;
    /// <summary>
    /// Sexual content that includes an individual who is under 18 years old.
    /// </summary>
    property SexualOrMinors: Boolean read FSexualminors write FSexualminors;
    /// <summary>
    /// Content that depicts death, violence, or physical injury.
    /// </summary>
    property Violence: Boolean read FViolence write FViolence;
    /// <summary>
    /// Content that depicts death, violence, or physical injury in graphic detail.
    /// </summary>
    property ViolenceOrGraphic: Boolean read FViolencegraphic write FViolencegraphic;
  end;

  TResult = class
  private
    FCategories: TCategories;
    FCategory_scores: TCategoryScores;
    FFlagged: Boolean;
  public
    /// <summary>
    /// A list of the categories, and whether they are flagged or not.
    /// </summary>
    property Categories: TCategories read FCategories write FCategories;
    /// <summary>
    /// A list of the categories along with their scores as predicted by model.
    /// </summary>
    property CategoryScores: TCategoryScores read FCategory_scores write FCategory_scores;
    /// <summary>
    /// Whether the content violates OpenAI's usage policies.
    /// </summary>
    /// <seealso>https://platform.openai.com/policies/usage-policies</seealso>
    property Flagged: Boolean read FFlagged write FFlagged;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents policy compliance report by OpenAI's content moderation model against a given input.
  /// </summary>
  TModerations = class
  private
    FId: string;
    FModel: string;
    FResults: TArray<TResult>;
  public
    /// <summary>
    /// The unique identifier for the moderation request.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The model used to generate the moderation results.
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// A list of moderation objects.
    /// </summary>
    property Results: TArray<TResult> read FResults write FResults;
    destructor Destroy; override;
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
  FCategories.Free;
  FCategory_scores.Free;
  inherited;
end;

{ TModerations }

destructor TModerations.Destroy;
var
  Item: TResult;
begin
  for Item in FResults do
    Item.Free;
  inherited;
end;

end.


unit OpenAI.Files;

interface

uses
  System.Classes, System.SysUtils, System.Net.Mime, OpenAI.API.Params,
  OpenAI.API;

{$SCOPEDENUMS ON}

type
  TFileCreatePurpose = (FineTune, Answers, Search, Classifications);

  TFileCreatePurposeHelper = record helper for TFileCreatePurpose
    function ToString: string;
  end;

  TFileUploadParams = class(TMultipartFormData)
    /// <summary>
    /// Name of the JSON Lines file to be uploaded.
    /// If the purpose is set to "fine-tune", the file will be used for fine-tuning.
    /// </summary>
    function &File(const FileName: string): TFileUploadParams; overload;
    /// <summary>
    /// Name of the JSON Lines file to be uploaded.
    /// If the purpose is set to "fine-tune", the file will be used for fine-tuning.
    /// </summary>
    function &File(const Stream: TStream; const FileName: string): TFileUploadParams; overload;
    /// <summary>
    /// The intended purpose of the uploaded documents.
    /// Use "fine-tune" for fine-tuning. This allows us to validate the format of the uploaded file.
    /// Variants: ['fine-tune', 'answers', 'search', 'classifications']
    /// </summary>
    function Purpose(const Value: string): TFileUploadParams; overload;
    /// <summary>
    /// The intended purpose of the uploaded documents.
    /// Use "fine-tune" for Fine-tuning. This allows us to validate the format of the uploaded file.
    /// </summary>
    function Purpose(const Value: TFileCreatePurpose): TFileUploadParams; overload;
    constructor Create; reintroduce;
  end;

  /// <summary>
  /// The File object represents a document that has been uploaded to OpenAI.
  /// </summary>
  TFile = class
  private
    FBytes: Int64;
    FCreated_at: Int64;
    FFilename: string;
    FId: string;
    FObject: string;
    FPurpose: string;
    FStatus: string;
    FStatus_details: string;
  public
    /// <summary>
    /// The file identifier, which can be referenced in the API endpoints.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type, which is always "file".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The size of the file in bytes.
    /// </summary>
    property Bytes: Int64 read FBytes write FBytes;
    /// <summary>
    /// The Unix timestamp (in seconds) for when the file was created.
    /// </summary>
    property CreatedAt: Int64 read FCreated_at write FCreated_at;
    /// <summary>
    /// The name of the file.
    /// </summary>
    property FileName: string read FFilename write FFilename;
    /// <summary>
    /// The intended purpose of the file. Currently, only "fine-tune" is supported.
    /// </summary>
    property Purpose: string read FPurpose write FPurpose;
    /// <summary>
    /// The current status of the file, which can be either uploaded, processed, pending, error, deleting or deleted.
    /// </summary>
    property Status: string read FStatus write FStatus;
    /// <summary>
    /// Additional details about the status of the file. If the file is in the error state,
    /// this will include a message describing the error.
    /// </summary>
    property StatusDetails: string read FStatus_details write FStatus_details;
  end;

  TFiles = class
  private
    FData: TArray<TFile>;
    FObject: string;
  public
    property Data: TArray<TFile> read FData write FData;
    property &Object: string read FObject write FObject;
    destructor Destroy; override;
  end;

  TDeletedInfo = class
  private
    FDeleted: Boolean;
    FId: string;
    FObject: string;
  public
    property Deleted: Boolean read FDeleted write FDeleted;
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
  end;

  TFilesRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Returns a list of files that belong to the user's organization.
    /// </summary>
    function List: TFiles;
    /// <summary>
    /// Upload a file that contains document(s) to be used across various endpoints/features.
    /// Currently, the size of all the files uploaded by one organization can be up to 1 GB.
    /// Please contact us if you need to increase the storage limit.
    /// </summary>
    function Upload(ParamProc: TProc<TFileUploadParams>): TFile;
    /// <summary>
    /// Delete a file.
    /// </summary>
    function Delete(const FileId: string = ''): TDeletedInfo;
    /// <summary>
    /// Returns information about a specific file.
    /// </summary>
    function Retrieve(const FileId: string = ''): TFile;
    /// <summary>
    /// Returns the contents of the specified file
    /// </summary>
    procedure Download(const FileId: string; Stream: TStream);
  end;

implementation

{ TFilesRoute }

function TFilesRoute.Upload(ParamProc: TProc<TFileUploadParams>): TFile;
begin
  Result := API.PostForm<TFile, TFileUploadParams>('files', ParamProc);
end;

function TFilesRoute.Delete(const FileId: string): TDeletedInfo;
begin
  Result := API.Delete<TDeletedInfo>('files/' + FileId);
end;

procedure TFilesRoute.Download(const FileId: string; Stream: TStream);
begin
  API.GetFile('files/' + FileId + '/content', Stream);
end;

function TFilesRoute.List: TFiles;
begin
  Result := API.Get<TFiles>('files');
end;

function TFilesRoute.Retrieve(const FileId: string): TFile;
begin
  Result := API.Get<TFile>('files/' + FileId);
end;

{ TFiles }

destructor TFiles.Destroy;
var
  Item: TFile;
begin
  for Item in FData do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TFileUploadParams }

function TFileUploadParams.&File(const FileName: string): TFileUploadParams;
begin
  AddFile('file', FileName);
  Result := Self;
end;

constructor TFileUploadParams.Create;
begin
  inherited Create(True);
end;

function TFileUploadParams.&File(const Stream: TStream; const FileName: string): TFileUploadParams;
begin
  AddStream('file', Stream, FileName);
  Result := Self;
end;

function TFileUploadParams.Purpose(const Value: TFileCreatePurpose): TFileUploadParams;
begin
  Result := Purpose(Value.ToString);
end;

function TFileUploadParams.Purpose(const Value: string): TFileUploadParams;
begin
  AddField('purpose', Value);
  Result := Self;
end;

{ TFileCreatePurposeHelper }

function TFileCreatePurposeHelper.ToString: string;
begin
  case Self of
    TFileCreatePurpose.FineTune:
      Result := 'fine-tune';
    TFileCreatePurpose.Answers:
      Result := 'answers';
    TFileCreatePurpose.Search:
      Result := 'search';
    TFileCreatePurpose.Classifications:
      Result := 'classifications';
  end;
end;

end.


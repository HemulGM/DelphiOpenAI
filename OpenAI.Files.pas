unit OpenAI.Files;

interface

uses
  System.Classes, System.SysUtils, System.Net.Mime, OpenAI.Params, OpenAI.API;

type
  TFileCreateParams = class(TMultipartFormData)
    /// <summary>
    /// Name of the JSON Lines file to be uploaded.
    /// If the purpose is set to "fine-tune", each line is a JSON record with "prompt" and "completion"
    /// fields representing your training examples.
    /// </summary>
    function &File(const FileName: string): TFileCreateParams; overload;
    /// <summary>
    /// Name of the JSON Lines file to be uploaded.
    /// If the purpose is set to "fine-tune", each line is a JSON record with "prompt" and "completion"
    /// fields representing your training examples.
    /// </summary>
    function &File(const Stream: TStream; const FileName: string): TFileCreateParams; overload;
    /// <summary>
    /// The intended purpose of the uploaded documents.
    /// Use "fine-tune" for Fine-tuning. This allows us to validate the format of the uploaded file.
    /// </summary>
    function Purpose(const Value: string): TFileCreateParams; overload;
  end;

  TFile = class
  private
    FBytes: Int64;
    FCreated_at: Int64;
    FFilename: string;
    FId: string;
    FObject: string;
    FPurpose: string;
  public
    property Bytes: Int64 read FBytes write FBytes;
    property CreatedAt: Int64 read FCreated_at write FCreated_at;
    property FileName: string read FFilename write FFilename;
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property Purpose: string read FPurpose write FPurpose;
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

  TFileDeleted = class
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
    function Create(ParamProc: TProc<TFileCreateParams>): TFile;
    /// <summary>
    /// Delete a file.
    /// </summary>
    function Delete(const FileId: string): TFileDeleted;
    /// <summary>
    /// Returns information about a specific file.
    /// </summary>
    function Retrieve(const FileId: string): TFile;
    /// <summary>
    /// Returns the contents of the specified file
    /// </summary>
    procedure Download(const FileId: string; Stream: TStream);
  end;

implementation

{ TFilesRoute }

function TFilesRoute.Create(ParamProc: TProc<TFileCreateParams>): TFile;
begin
  Result := API.PostForm<TFile, TFileCreateParams>('files', ParamProc);
end;

function TFilesRoute.Delete(const FileId: string): TFileDeleted;
begin
  Result := API.Delete<TFileDeleted>('files/' + FileId);
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
begin
  for var Item in FData do
    if Assigned(Item) then
      Item.Free;
  inherited;
end;

{ TFileCreateParams }

function TFileCreateParams.&File(const FileName: string): TFileCreateParams;
begin
  AddFile('file', FileName);
  Result := Self;
end;

function TFileCreateParams.&File(const Stream: TStream; const FileName: string): TFileCreateParams;
begin
  AddStream('file', Stream, FileName);
  Result := Self;
end;

function TFileCreateParams.Purpose(const Value: string): TFileCreateParams;
begin
  AddField('purpose', Value);
  Result := Self;
end;

end.


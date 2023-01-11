unit OpenAI.Errors;

interface

type
  TGPTError = class
  private
    FMessage: string;
    FType: string;
    FParam: string;
    FCode: Int64;
  public
    property Message: string read FMessage write FMessage;
    property &Type: string read FType write FType;
    property Param: string read FParam write FParam;
    property Code: Int64 read FCode write FCode;
  end;

  TGPTErrorResponse = class
  private
    FError: TGPTError;
  public
    property Error: TGPTError read FError write FError;
    destructor Destroy; override;
  end;

implementation

{ TGPTErrorResponse }

destructor TGPTErrorResponse.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

end.


unit OpenAI.Types;

interface

type
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

  TBase64Data = record
    ContentType: string;
    Data: string;
    function ToString: string;
  end;

implementation

{ TBase64Data }

function TBase64Data.ToString: string;
begin
  Result := 'data:' + ContentType + ';base64,' + Data;
end;

end.


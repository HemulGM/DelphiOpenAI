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

implementation

end.


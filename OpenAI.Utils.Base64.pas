unit OpenAI.Utils.Base64;

interface

uses
  System.SysUtils, System.NetEncoding, System.Classes, System.Net.Mime,
  OpenAI.Types;

function FileToBase64(const FileName: string): TBase64Data;

implementation

function FileToBase64(const FileName: string): TBase64Data;
begin
  var FS := TFileStream.Create(FileName, fmOpenRead);
  try
    var Base64 := TStringStream.Create('', TEncoding.UTF8);
    try
      TBase64StringEncoding.Base64String.Encode(FS, Base64);
      Result.Data := Base64.DataString;
      var LType: string;
      var LKind: TMimeTypes.TKind;
      TMimeTypes.Default.GetFileInfo(FileName, LType, LKind);
      Result.ContentType := LType;
    finally
      Base64.Free;
    end;
  finally
    FS.Free;
  end;
end;

end.


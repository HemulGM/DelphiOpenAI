unit OpenAI.Utils.Base64;

interface

uses
  System.SysUtils, System.NetEncoding, System.Classes, System.Net.Mime,
  OpenAI.Types;

function FileToBase64(const FileName: string): TBase64Data;

function StreamToBase64(Stream: TStream; const ContentType: string): TBase64Data;

function GetFileContentType(const FileName: string): string;

implementation

function GetFileContentType(const FileName: string): string;
begin
  var LKind: TMimeTypes.TKind;
  TMimeTypes.Default.GetFileInfo(FileName, Result, LKind);
end;

function FileToBase64(const FileName: string): TBase64Data;
begin
  var FS := TFileStream.Create(FileName, fmOpenRead);
  try
    var Base64 := TStringStream.Create('', TEncoding.UTF8);
    try
      TBase64StringEncoding.Base64String.Encode(FS, Base64);
      Result.Data := Base64.DataString;
      Result.ContentType := GetFileContentType(FileName);
    finally
      Base64.Free;
    end;
  finally
    FS.Free;
  end;
end;

function StreamToBase64(Stream: TStream; const ContentType: string): TBase64Data;
begin
  var Base64 := TStringStream.Create('', TEncoding.UTF8);
  try
    TBase64StringEncoding.Base64String.Encode(Stream, Base64);
    Result.Data := Base64.DataString;
    Result.ContentType := ContentType;
  finally
    Base64.Free;
  end;
end;

end.


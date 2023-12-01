unit OpenAI.Utils.Base64;

interface

uses
  System.SysUtils, System.NetEncoding, System.Classes, System.Net.Mime,
  OpenAI.Types;

function FileToBase64(const FileName: TFileName): TBase64Data;

function StreamToBase64(Stream: TStream; const ContentType: string): TBase64Data;

function GetFileContentType(const FileName: TFileName): string;

implementation

function GetFileContentType(const FileName: TFileName): string;
var
  LKind: TMimeTypes.TKind;
begin
  TMimeTypes.Default.GetFileInfo(FileName, Result, LKind);
end;

function FileToBase64(const FileName: TFileName): TBase64Data;
var
  FS: TFileStream;
  Base64: TStringStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    Base64 := TStringStream.Create('', TEncoding.UTF8);
    try
      {$IF RTLVersion >= 35.0}
      TNetEncoding.Base64String.Encode(FS, Base64);
      {$ELSE}
      TNetEncoding.Base64.Encode(FS, Base64);
      {$ENDIF}
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
var
  Base64: TStringStream;
begin
  Base64 := TStringStream.Create('', TEncoding.UTF8);
  try
    {$IF RTLVersion >= 35.0}
    TNetEncoding.Base64String.Encode(Stream, Base64);
    {$ELSE}
    TNetEncoding.Base64.Encode(Stream, Base64);
    {$ENDIF}
    Result.Data := Base64.DataString;
    Result.ContentType := ContentType;
  finally
    Base64.Free;
  end;
end;

end.


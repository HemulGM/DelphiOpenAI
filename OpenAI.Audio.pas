unit OpenAI.Audio;

interface

uses
  System.Classes, System.SysUtils, System.Net.Mime, OpenAI.API.Params,
  OpenAI.API;

{$SCOPEDENUMS ON}

type
  TAudioResponseFormat = (Json, Text, Srt, VerboseJson, Vtt);

  TAudioResponseFormatHelper = record helper for TAudioResponseFormat
    function ToString: string;
  end;

  TAudioTranscription = class(TMultipartFormData)
    /// <summary>
    /// The audio file to transcribe, in one of these formats: mp3, mp4, mpeg, mpga, m4a, wav, or webm.
    /// </summary>
    function &File(const FileName: string): TAudioTranscription; overload;
    /// <summary>
    /// The audio file to transcribe, in one of these formats: mp3, mp4, mpeg, mpga, m4a, wav, or webm.
    /// </summary>
    function &File(const Stream: TStream; const FileName: string): TAudioTranscription; overload;
    /// <summary>
    /// ID of the model to use. Only whisper-1 is currently available.
    /// </summary>
    function Model(const Value: string): TAudioTranscription; overload;
    /// <summary>
    /// An optional text to guide the model's style or continue a previous audio segment.
    /// The prompt should match the audio language.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/speech-to-text/prompting</seealso>
    function Prompt(const Value: string): TAudioTranscription; overload;
    /// <summary>
    /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
    /// </summary>
    function ResponseFormat(const Value: string): TAudioTranscription; overload;
    /// <summary>
    /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
    /// </summary>
    function ResponseFormat(const Value: TAudioResponseFormat = TAudioResponseFormat.Json): TAudioTranscription; overload;
    /// <summary>
    /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use
    /// log probability to automatically increase the temperature until certain thresholds are hit.
    /// </summary>
    function Temperature(const Value: Single = 0): TAudioTranscription;
    /// <summary>
    /// The language of the input audio. Supplying the input language in ISO-639-1 format will improve accuracy and latency (like en, ru, uk).
    /// </summary>
    function Language(const Value: string): TAudioTranscription; overload;
    constructor Create; reintroduce;
  end;

  TAudioTranslation = class(TMultipartFormData)
    /// <summary>
    /// The audio file to translate, in one of these formats: mp3, mp4, mpeg, mpga, m4a, wav, or webm.
    /// </summary>
    function &File(const FileName: string): TAudioTranslation; overload;
    /// <summary>
    /// The audio file to transcribe, in one of these formats: mp3, mp4, mpeg, mpga, m4a, wav, or webm.
    /// </summary>
    function &File(const Stream: TStream; const FileName: string): TAudioTranslation; overload;
    /// <summary>
    /// ID of the model to use. Only whisper-1 is currently available.
    /// </summary>
    function Model(const Value: string): TAudioTranslation; overload;
    /// <summary>
    /// An optional text to guide the model's style or continue a previous audio segment. The prompt should be in English.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/speech-to-text/prompting</seealso>
    function Prompt(const Value: string): TAudioTranslation; overload;
    /// <summary>
    /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
    /// </summary>
    function ResponseFormat(const Value: string = 'json'): TAudioTranslation;
    /// <summary>
    /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use
    /// log probability to automatically increase the temperature until certain thresholds are hit.
    /// </summary>
    function Temperature(const Value: Single = 0): TAudioTranslation;
  end;

  TAudioText = class
  private
    FText: string;
  public
    property Text: string read FText write FText;
  end;

  /// <summary>
  /// Learn how to turn audio into text.
  /// </summary>
  TAudioRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Transcribes audio into the input language.
    /// </summary>
    function CreateTranscription(ParamProc: TProc<TAudioTranscription>): TAudioText;
    /// <summary>
    /// Translates audio into into English.
    /// </summary>
    function CreateTranslation(ParamProc: TProc<TAudioTranslation>): TAudioText;
  end;

implementation

{ TAudioRoute }

function TAudioRoute.CreateTranscription(ParamProc: TProc<TAudioTranscription>): TAudioText;
begin
  Result := API.PostForm<TAudioText, TAudioTranscription>('audio/transcriptions', ParamProc);
end;

function TAudioRoute.CreateTranslation(ParamProc: TProc<TAudioTranslation>): TAudioText;
begin
  Result := API.PostForm<TAudioText, TAudioTranslation>('audio/translations', ParamProc);
end;

{ TAudioTranscription }

function TAudioTranscription.&File(const FileName: string): TAudioTranscription;
begin
  AddFile('file', FileName);
  Result := Self;
end;

constructor TAudioTranscription.Create;
begin
  inherited Create(True);
  Model('whisper-1');
end;

function TAudioTranscription.&File(const Stream: TStream; const FileName: string): TAudioTranscription;
begin
  AddStream('file', Stream, FileName);
  Result := Self;
end;

function TAudioTranscription.Language(const Value: string): TAudioTranscription;
begin
  AddField('language', Value);
  Result := Self;
end;

function TAudioTranscription.Temperature(const Value: Single): TAudioTranscription;
begin
  AddField('temperature', Value.ToString);
  Result := Self;
end;

function TAudioTranscription.Prompt(const Value: string): TAudioTranscription;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TAudioTranscription.ResponseFormat(const Value: TAudioResponseFormat): TAudioTranscription;
begin
  Result := ResponseFormat(Value.ToString);
end;

function TAudioTranscription.ResponseFormat(const Value: string): TAudioTranscription;
begin
  AddField('response_format', Value);
  Result := Self;
end;

function TAudioTranscription.Model(const Value: string): TAudioTranscription;
begin
  AddField('model', Value);
  Result := Self;
end;

{ TAudioTranslation }

function TAudioTranslation.&File(const FileName: string): TAudioTranslation;
begin
  AddFile('file', FileName);
  Result := Self;
end;

function TAudioTranslation.&File(const Stream: TStream; const FileName: string): TAudioTranslation;
begin
  AddStream('file', Stream, FileName);
  Result := Self;
end;

function TAudioTranslation.Temperature(const Value: Single): TAudioTranslation;
begin
  AddField('temperature', Value.ToString);
  Result := Self;
end;

function TAudioTranslation.Prompt(const Value: string): TAudioTranslation;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TAudioTranslation.ResponseFormat(const Value: string): TAudioTranslation;
begin
  AddField('response_format', Value);
  Result := Self;
end;

function TAudioTranslation.Model(const Value: string): TAudioTranslation;
begin
  AddField('model', Value);
  Result := Self;
end;

{ TAudioResponseFormatHelper }

function TAudioResponseFormatHelper.ToString: string;
begin
  case Self of
    TAudioResponseFormat.Json:
      Result := 'json';
    TAudioResponseFormat.Text:
      Result := 'text';
    TAudioResponseFormat.Srt:
      Result := 'srt';
    TAudioResponseFormat.VerboseJson:
      Result := 'verbose_json';
    TAudioResponseFormat.Vtt:
      Result := 'vtt';
  end;
end;

end.


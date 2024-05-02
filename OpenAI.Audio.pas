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

  TAudioFileResponseFormat = (MP3, OPUS, AAC, FLAC, WAV, PCM);

  TAudioFileResponseFormatHelper = record helper for TAudioFileResponseFormat
    function ToString: string;
  end;

  TAudioTranscription = class(TMultipartFormData)
    /// <summary>
    /// Required.
    /// The audio file object (not file name) to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
    /// </summary>
    function &File(const FileName: TFileName): TAudioTranscription; overload;
    /// <summary>
    /// Required.
    /// The audio file object (not file name) to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
    /// </summary>
    function &File(const Stream: TStream; const FileName: TFileName): TAudioTranscription; overload;
    /// <summary>
    /// Required.
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
    function ResponseFormat(const Value: TAudioResponseFormat): TAudioTranscription; overload;
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
    /// <summary>
    /// The timestamp granularities to populate for this transcription.
    /// response_format must be set verbose_json to use timestamp granularities.
    /// Either or both of these options are supported: word, or segment.
    /// Note: There is no additional latency for segment timestamps,
    /// but generating word timestamps incurs additional latency.
    /// </summary>
    function TimestampGranularities(const Value: string): TAudioTranscription; overload;
    constructor Create; reintroduce;
  end;

  TAudioTranslation = class(TMultipartFormData)
    /// <summary>
    /// Required.
    /// The audio file object (not file name) translate, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
    /// </summary>
    function &File(const FileName: TFileName): TAudioTranslation; overload;
    /// <summary>
    /// Required.
    /// The audio file object (not file name) translate, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
    /// </summary>
    function &File(const Stream: TStream; const FileName: TFileName): TAudioTranslation; overload;
    /// <summary>
    /// Required.
    /// ID of the model to use. Only whisper-1 (which is powered by our open source Whisper V2 model) is currently available.
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
    function ResponseFormat(const Value: string): TAudioTranslation; overload;
    /// <summary>
    /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
    /// </summary>
    function ResponseFormat(const Value: TAudioResponseFormat): TAudioTranslation; overload;
    /// <summary>
    /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use
    /// log probability to automatically increase the temperature until certain thresholds are hit.
    /// </summary>
    function Temperature(const Value: Single): TAudioTranslation;
    constructor Create; reintroduce;
  end;

  TAudioSpeechParams = class(TJSONParam)
    /// <summary>
    /// One of the available TTS models: tts-1 or tts-1-hd
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/models/tts</seealso>
    function Model(const Value: string): TAudioSpeechParams;
    /// <summary>
    /// The text to generate audio for. The maximum length is 4096 characters.
    /// </summary>
    function Input(const Value: string): TAudioSpeechParams; overload;
    /// <summary>
    /// The voice to use when generating the audio.
    /// Supported voices are alloy, echo, fable, onyx, nova, and shimmer.
    /// Previews of the voices are available in the Text to speech guide.
    /// </summary>
    /// <seealso>https://platform.openai.com/docs/guides/text-to-speech/voice-options</seealso>
    function Voice(const Value: string): TAudioSpeechParams; overload;
    /// <summary>
    /// The format to audio in. Supported formats are mp3, opus, aac, flac, wav, and pcm.
    /// </summary>
    function ResponseFormat(const Value: string): TAudioSpeechParams; overload;
    /// <summary>
    /// The format to audio in. Supported formats are mp3, opus, aac, flac, wav, and pcm.
    /// </summary>
    function ResponseFormat(const Value: TAudioFileResponseFormat): TAudioSpeechParams; overload;
    /// <summary>
    /// The speed of the generated audio. Select a value from 0.25 to 4.0. 1.0 is the default.
    /// </summary>
    function Speed(const Value: Single): TAudioSpeechParams;
    constructor Create; override;
  end;

  /// <summary>
  /// Represents a transcription response returned by model, based on the provided input.
  /// </summary>
  TAudioText = class
  private
    FText: string;
  public
    property Text: string read FText write FText;
  end;

  TAudioTranscriptionWord = class
  private
    FWord: string;
    FStart: Extended;
    FEnd: Extended;
  public
    /// <summary>
    /// The text content of the word.
    /// </summary>
    property Word: string read FWord write FWord;
    /// <summary>
    /// Start time of the word in seconds.
    /// </summary>
    property Start: Extended read FStart write FStart;
    /// <summary>
    /// End time of the word in seconds.
    /// </summary>
    property &End: Extended read FEnd write FEnd;
  end;

  TAudioTranscriptionSegment = class
  private
    FId: Int64;
    FSeek: Int64;
    FStart: Extended;
    FEnd: Extended;
    FText: string;
    FTokens: TArray<Int64>;
    FTemperature: Extended;
    FAvg_logprob: Extended;
    FCompression_ratio: Extended;
    FNo_speech_prob: Extended;
  public
    /// <summary>
    /// Unique identifier of the segment.
    /// </summary>
    property Id: Int64 read FId write FId;
    /// <summary>
    /// Seek offset of the segment.
    /// </summary>
    property Seek: Int64 read FSeek write FSeek;
    /// <summary>
    /// Start time of the segment in seconds.
    /// </summary>
    property Start: Extended read FStart write FStart;
    /// <summary>
    /// End time of the segment in seconds.
    /// </summary>
    property &End: Extended read FEnd write FEnd;
    /// <summary>
    /// Text content of the segment.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// Array of token IDs for the text content.
    /// </summary>
    property Tokens: TArray<Int64> read FTokens write FTokens;
    /// <summary>
    /// Temperature parameter used for generating the segment.
    /// </summary>
    property Temperature: Extended read FTemperature write FTemperature;
    /// <summary>
    /// Average logprob of the segment. If the value is lower than -1, consider the logprobs failed.
    /// </summary>
    property AVGLogprob: Extended read FAvg_logprob write FAvg_logprob;
    /// <summary>
    /// Compression ratio of the segment. If the value is greater than 2.4, consider the compression failed.
    /// </summary>
    property CompressionRatio: Extended read FCompression_ratio write FCompression_ratio;
    /// <summary>
    /// Probability of no speech in the segment. If the value is higher than 1.0 and
    /// the avg_logprob is below -1, consider this segment silent.
    /// </summary>
    property NoSpeechProb: Extended read FNo_speech_prob write FNo_speech_prob;
  end;

  /// <summary>
  /// Represents a transcription response returned by model, based on the provided input.
  /// </summary>
  TAudioTranscriptionObject = class
  private
    FText: string;
    FLanguage: string;
    FDuration: string;
    FWords: TArray<TAudioTranscriptionWord>;
    FSegments: TArray<TAudioTranscriptionSegment>;
  public
    /// <summary>
    /// The transcribed text.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// The language of the input audio.
    /// </summary>
    property Language: string read FLanguage write FLanguage;
    /// <summary>
    /// The duration of the input audio.
    /// </summary>
    property Duration: string read FDuration write FDuration;
    /// <summary>
    /// Extracted words and their corresponding timestamps.
    /// </summary>
    property Words: TArray<TAudioTranscriptionWord> read FWords write FWords;
    /// <summary>
    /// Segments of the transcribed text and their corresponding details.
    /// </summary>
    property Segments: TArray<TAudioTranscriptionSegment> read FSegments write FSegments;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Learn how to turn audio into text or text into audio.
  /// </summary>
  TAudioRoute = class(TOpenAIAPIRoute)
  public
    /// <summary>
    /// Transcribes audio into the input language.
    /// </summary>
    function CreateTranscription(ParamProc: TProc<TAudioTranscription>): TAudioTranscriptionObject;
    /// <summary>
    /// Translates audio into into English.
    /// </summary>
    function CreateTranslation(ParamProc: TProc<TAudioTranslation>): TAudioText;
    /// <summary>
    /// Generates audio from the input text.
    /// </summary>
    procedure CreateSpeech(ParamProc: TProc<TAudioSpeechParams>; Stream: TStream);
  end;

implementation

{ TAudioRoute }

procedure TAudioRoute.CreateSpeech(ParamProc: TProc<TAudioSpeechParams>; Stream: TStream);
begin
  API.Post<TAudioSpeechParams>('audio/speech', ParamProc, Stream);
end;

function TAudioRoute.CreateTranscription(ParamProc: TProc<TAudioTranscription>): TAudioTranscriptionObject;
begin
  Result := API.PostForm<TAudioTranscriptionObject, TAudioTranscription>('audio/transcriptions', ParamProc);
end;

function TAudioRoute.CreateTranslation(ParamProc: TProc<TAudioTranslation>): TAudioText;
begin
  Result := API.PostForm<TAudioText, TAudioTranslation>('audio/translations', ParamProc);
end;

{ TAudioTranscription }

function TAudioTranscription.&File(const FileName: TFileName): TAudioTranscription;
begin
  AddFile('file', FileName);
  Result := Self;
end;

constructor TAudioTranscription.Create;
begin
  inherited Create(True);
  Model('whisper-1');
end;

function TAudioTranscription.&File(const Stream: TStream; const FileName: TFileName): TAudioTranscription;
begin
  AddStream('file', Stream, False, FileName);
  Result := Self;
end;

function TAudioTranscription.Language(const Value: string): TAudioTranscription;
begin
  AddField('language', Value);
  Result := Self;
end;

function TAudioTranscription.Temperature(const Value: Single): TAudioTranscription;
begin
  AddField('temperature', FormatFloat('0,0', Value));
  Result := Self;
end;

function TAudioTranscription.TimestampGranularities(const Value: string): TAudioTranscription;
begin
  AddField('timestamp_granularities[]', Value);
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

function TAudioTranslation.&File(const FileName: TFileName): TAudioTranslation;
begin
  AddFile('file', FileName);
  Result := Self;
end;

constructor TAudioTranslation.Create;
begin
  inherited Create(True);
end;

function TAudioTranslation.&File(const Stream: TStream; const FileName: TFileName): TAudioTranslation;
begin
  AddStream('file', Stream, False, FileName);
  Result := Self;
end;

function TAudioTranslation.Temperature(const Value: Single): TAudioTranslation;
begin
  AddField('temperature', FormatFloat('0,0', Value));
  Result := Self;
end;

function TAudioTranslation.Prompt(const Value: string): TAudioTranslation;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TAudioTranslation.ResponseFormat(const Value: TAudioResponseFormat): TAudioTranslation;
begin
  AddField('response_format', Value.ToString);
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

{ TAudioSpeechParams }

constructor TAudioSpeechParams.Create;
begin
  inherited;
  Model('tts-1');
  Voice('alloy');
end;

function TAudioSpeechParams.Input(const Value: string): TAudioSpeechParams;
begin
  Result := TAudioSpeechParams(Add('input', Value));
end;

function TAudioSpeechParams.Model(const Value: string): TAudioSpeechParams;
begin
  Result := TAudioSpeechParams(Add('model', Value));
end;

function TAudioSpeechParams.ResponseFormat(const Value: TAudioFileResponseFormat): TAudioSpeechParams;
begin
  Result := TAudioSpeechParams(Add('response_format', Value.ToString));
end;

function TAudioSpeechParams.ResponseFormat(const Value: string): TAudioSpeechParams;
begin
  Result := TAudioSpeechParams(Add('response_format', Value));
end;

function TAudioSpeechParams.Speed(const Value: Single): TAudioSpeechParams;
begin
  Result := TAudioSpeechParams(Add('speed', Value));
end;

function TAudioSpeechParams.Voice(const Value: string): TAudioSpeechParams;
begin
  Result := TAudioSpeechParams(Add('voice', Value));
end;

{ TAudioFileResponseFormatHelper }

function TAudioFileResponseFormatHelper.ToString: string;
begin
  case Self of
    TAudioFileResponseFormat.MP3:
      Exit('mp3');
    TAudioFileResponseFormat.OPUS:
      Exit('opus');
    TAudioFileResponseFormat.AAC:
      Exit('aac');
    TAudioFileResponseFormat.FLAC:
      Exit('flac');
    TAudioFileResponseFormat.WAV:
      Exit('wav');
    TAudioFileResponseFormat.PCM:
      Exit('pcm');
  else
    Exit('mp3');
  end;
end;

{ TAudioTranscriptionObject }

destructor TAudioTranscriptionObject.Destroy;
var
  AWord: TAudioTranscriptionWord;
  ASegment: TAudioTranscriptionSegment;
begin
  for AWord in FWords do
    AWord.Free;
  for ASegment in FSegments do
    ASegment.Free;
  inherited;
end;

end.


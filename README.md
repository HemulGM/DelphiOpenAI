# Delphi OpenAI API
![GitHub](https://img.shields.io/github/license/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/github/last-commit/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/badge/coverage-100%25-green)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.4+-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)

The library provides access to the API of the [OpenAI service](https://openai.com/api/), on the basis of which [ChatGPT](https://openai.com/blog/chatgpt) works and, for example, the generation of images from text using `DALL-E`.
`Delphi 10.4+` is required to work with the library. It is possible to build under `Delphi 10.3`.
This library is a `TOpenAI` class for the main TComponent for more convenient work.

❗*This is an unofficial library. OpenAI does not provide any official library for Delphi.*

**Coverage**

<img src="https://github.com/HemulGM/ChatGPT.API/blob/main/OpenAL-GPT3.png?raw=true" height="150" align="right">

|API|Status|
|---|---|
|Models|🟢 Done|
|Completions|🟢 Done|
|Chat|🟠 Working|
|Edits|🟢 Done|
|Images|🟢 Done|
|Embeddings|🟢 Done|
|Audio|🟠 Working|
|Files|🟢 Done|
|Fine-tunes|🟢 Done|
|Moderations|🟢 Done|
|Engines (Depricated)|🟢 Done|

# ⚒️ Installation

You can install the package from `GetIt` [directly](https://getitnow.embarcadero.com/openai-for-delphi) in the IDE. Or, to use the library, just add the `root` folder to the IDE library path, or your project source path.

# 🌳 Usage

The library needs to be configured with your account's secret key which is available on the [website](https://beta.openai.com/account/api-keys). 

Due to the fact that there can be many parameters and not all of them are required, they are configured using an anonymous function.

**Initialization**

```Pascal
uses OpenAI;

var OpenAI := TOpenAIComponent.Create(Self, API_TOKEN);
```

or 

```Pascal
uses OpenAI;

var OpenAI: IOpenAI := TOpenAI.Create(API_TOKEN);
```

**Models**
```Pascal
var Models := OpenAI.Model.List();
try
  for var Model in Models.Data do
    MemoChat.Lines.Add(Model.Id);
finally
  Models.Free;
end;
```

**Completions (for chat)**
```Pascal
var Completions := OpenAI.Completion.Create(
  procedure(Params: TCompletionParams)
  begin
    Params.Prompt(MemoPrompt.Text);
    Params.MaxTokens(2048);
  end);
try
  for var Choice in Completions.Choices do
    MemoChat.Lines.Add(Choice.Index.ToString + ' ' + Choice.Text);
finally
  Completions.Free;
end;
```

**Images Generations**
```Pascal
var Images := OpenAI.Image.Create(
  procedure(Params: TImageGenParams)
  begin
    Params.Prompt(MemoPrompt.Text);
    Params.ResponseFormat('url');
  end);
try
  for var Image in Images.Data do
    Image1.Bitmap.LoadFromUrl(Image.Url);
finally
  Images.Free;
end;
```

*Error handling*
```Pascal
try
  var Images := OpenAI.Image.Create(...);
except
  on E: OpenAIExceptionRateLimitError do
    ShowError('OpenAI Limit Error: ' + E.Message);
  on E: OpenAIException do
    ShowError('OpenAI Error: ' + E.Message);  
end;
```

Exceptions:
* OpenAIExceptionAPI - errors of wrapper
* OpenAIException - base exception
* OpenAIExceptionInvalidRequestError
* OpenAIExceptionRateLimitError
* OpenAIExceptionAuthenticationError
* OpenAIExceptionPermissionError
* OpenAIExceptionTryAgain
* OpenAIExceptionInvalidResponse - parse error

*Usage proxy*
```Pascal
OpenAI.API.Client.ProxySettings := TProxySettings.Create(ProxyHost, ProxyPort, ProxyUserName, ProxyPassword);
```

# ⚡ Examples
|Source|Preview|Source|Preview|
|---|---|---|---|
|[Playground (FMX)](https://github.com/HemulGM/DelphiOpenAIPlayground)|<img src="https://github.com/HemulGM/DelphiOpenAIPlayground/blob/main/preview.png?raw=true" height="150" align="right">|[ChatGPT (FMX)](https://github.com/HemulGM/ChatGPT)|<img src="https://github.com/HemulGM/ChatGPT/raw/main/preview.png?raw=true" height="150" align="right">|
|[DALL-E (FMX)](https://github.com/HemulGM/DALL-E)|<img src="https://github.com/HemulGM/DALL-E/raw/main/Res/preview.jpg?raw=true" height="150" align="right">|||

# 🚳 Requirements
This library does not require any 3rd party library. It works on recent Delphi versions (10.3+). Althought not fully tested, it should also work on all supported platforms (Windows, Linux, macOS, Android, iOS).

Since the library requires your secret API key, it's not recommended you use it on client applications, as your secret key will be exposed, unless you are sure about the security risks.

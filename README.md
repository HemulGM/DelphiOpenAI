# Delphi OpenAI API

![logo](https://github.com/HemulGM/DelphiOpenAI/blob/main/openai+delphi.png?raw=true)

___
![GitHub](https://img.shields.io/github/license/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/github/last-commit/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/badge/coverage-100%25-green)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3+-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)

This repositorty contains Swift implementation over [OpenAI](https://beta.openai.com/docs/api-reference/) public API.

❗*This is an unofficial library. OpenAI does not provide any official library for Delphi.*

- [What is OpenAI](#what-is-openai)
- [Installation](#installation)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Models](#models)
    - [Completions](#completions)
    - [Chats](#chats)
    - [Images](#images)
    - [Errors](#errors)
    - [Exceptions](#exceptions)
    - [Usage proxy](#proxy)
- [Examples](#examples)
- [Requirements](#requirements)
- [Links](#links)
- [License](#license)

**Coverage**

<img src="https://github.com/HemulGM/ChatGPT.API/blob/main/OpenAL-GPT3.png?raw=true" height="150" align="right">

|API|Status|
|---|---|
|Models|🟢 Done|
|Completions|🟢 Done|
|Chat|🟢 Done|
|Edits|🟢 Done|
|Images|🟢 Done|
|Embeddings|🟢 Done|
|Audio|🟢 Done|
|Files|🟢 Done|
|Fine-tunes|🟢 Done|
|Moderations|🟢 Done|
|Engines (Depricated)|🟢 Done|

## What is OpenAI

OpenAI is a non-profit artificial intelligence research organization founded in San Francisco, California in 2015. It was created with the purpose of advancing digital intelligence in ways that benefit humanity as a whole and promote societal progress. The organization strives to develop AI (Artificial Intelligence) programs and systems that can think, act and adapt quickly on their own – autonomously. OpenAI's mission is to ensure safe and responsible use of AI for civic good, economic growth and other public benefits; this includes cutting-edge research into important topics such as general AI safety, natural language processing, applied reinforcement learning methods, machine vision algorithms etc.

>The OpenAI API can be applied to virtually any task that involves understanding or generating natural language or code. We offer a spectrum of models with different levels of power suitable for different tasks, as well as the ability to fine-tune your own custom models. These models can be used for everything from content generation to semantic search and classification.

This library provides access to the API of the [OpenAI service](https://openai.com/api/), on the basis of which [ChatGPT](https://openai.com/blog/chatgpt) works and, for example, the generation of images from text using `DALL-E`.

## Installation

You can install the package from `GetIt` [directly](https://getitnow.embarcadero.com/openai-for-delphi) in the IDE. Or, to use the library, just add the `root` folder to the IDE library path, or your project source path.

## Usage

### Initialization

To initialize API instance you need to [obtain](https://beta.openai.com/account/api-keys) API token from your Open AI organization.

Once you have a token, you can initialize `TOpenAI` class, which is an entry point to the API.

Due to the fact that there can be many parameters and not all of them are required, they are configured using an anonymous function.

```Pascal
uses OpenAI;

var OpenAI := TOpenAIComponent.Create(Self, API_TOKEN);
```

or 

```Pascal
uses OpenAI;

var OpenAI: IOpenAI := TOpenAI.Create(API_TOKEN);
```

Once token you posses the token, and the instance is initialized you are ready to make requests.

### Models

```Pascal
var Models := OpenAI.Model.List();
try
  for var Model in Models.Data do
    MemoChat.Lines.Add(Model.Id);
finally
  Models.Free;
end;
```

### Completions

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

Review [Completions Documentation](https://beta.openai.com/docs/api-reference/completions) for more info.

### Chats

```Pascal
var Chat := OpenAI.Chat.Create(
  procedure(Params: TChatParams)
  begin
    Params.Messages([TChatMessageBuild.Create(TMessageRole.User, Text)]);
    Params.MaxTokens(1024);
  end);
try
  for var Choice in Chat.Choices do
    MemoChat.Lines.Add(Choice.Message.Content);
finally
  Chat.Free;
end;
```

Review [Chat Documentation](https://platform.openai.com/docs/guides/chat) for more info.

### Images
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

Review [Images Documentation](https://beta.openai.com/docs/api-reference/images) for more info.

### Errors

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

#### Exceptions

* OpenAIExceptionAPI - errors of wrapper
* OpenAIException - base exception
* OpenAIExceptionInvalidRequestError
* OpenAIExceptionRateLimitError
* OpenAIExceptionAuthenticationError
* OpenAIExceptionPermissionError
* OpenAIExceptionTryAgain
* OpenAIExceptionInvalidResponse - parse error

### Proxy

```Pascal
OpenAI.API.Client.ProxySettings := TProxySettings.Create(ProxyHost, ProxyPort, ProxyUserName, ProxyPassword);
```

## Examples
|Source|Preview|Source|Preview|
|---|---|---|---|
|[Playground (FMX)](https://github.com/HemulGM/DelphiOpenAIPlayground)|<img src="https://github.com/HemulGM/DelphiOpenAIPlayground/blob/main/preview.png?raw=true" height="150" align="right">|[ChatGPT (FMX)](https://github.com/HemulGM/ChatGPT)|<img src="https://github.com/HemulGM/ChatGPT/raw/main/preview.png?raw=true" height="150" align="right">|
|[DALL-E (FMX)](https://github.com/HemulGM/DALL-E)|<img src="https://github.com/HemulGM/DALL-E/raw/main/Res/preview.jpg?raw=true" height="150" align="right">|||

## Requirements
This library does not require any 3rd party library. It works on recent Delphi versions (10.3+). Althought not fully tested, it should also work on all supported platforms (Windows, Linux, macOS, Android, iOS).

Since the library requires your secret API key, it's not recommended you use it on client applications, as your secret key will be exposed, unless you are sure about the security risks.

## Links

- [OpenAI Documentation](https://beta.openai.com/docs/introduction)
- [OpenAI Playground](https://beta.openai.com/playground)
- [OpenAI Examples](https://beta.openai.com/examples)
- [Dall-E](https://labs.openai.com/)

## License

```
MIT License

Copyright (c) 2023 HemulGM

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

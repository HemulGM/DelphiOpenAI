# Delphi OpenAI API

![logo](https://github.com/HemulGM/DelphiOpenAI/blob/main/openai+delphi.png?raw=true)

___
![GitHub](https://img.shields.io/github/license/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/github/last-commit/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/badge/coverage-100%25-green)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3+-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)

This repositorty contains Delphi implementation over [OpenAI](https://beta.openai.com/docs/api-reference/) public API.

❗*This is an unofficial library. OpenAI does not provide any official library for Delphi.*

- [What is OpenAI](#what-is-openai)
- [Installation](#installation)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Models](#models)
    - [Completions](#completions)
    - [Chats](#chats)
    - [Images](#images)
    - [Function calling](#function-calling)
    - [Errors](#errors)
    - [Exceptions](#exceptions)
    - [Usage proxy](#proxy)
- [Examples](#examples)
- [Requirements](#requirements)
- [Links](#links)
- [License](#license)

<details>
  <summary> Coverage </summary>

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
|Fine-tunes (Depricated)|🟢 Done|
|Fine-tuning|🟢 Done|
|Moderations|🟢 Done|
|Engines (Depricated)|🟢 Done|

</details>

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
List and describe the various models available in the API. You can refer to the Models documentation to understand what models are available and the differences between them.

```Pascal
var Models := OpenAI.Model.List();
try
  for var Model in Models.Data do
    MemoChat.Lines.Add(Model.Id);
finally
  Models.Free;
end;
```

Review [Models Documentation](https://platform.openai.com/docs/api-reference/models) for more info.

### Completions
Given a prompt, the model will return one or more predicted completions, and can also return the probabilities of alternative tokens at each position.

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

Review [Completions Documentation](https://platform.openai.com/docs/api-reference/completions) for more info.

### Chats
Given a chat conversation, the model will return a chat completion response.
ChatGPT is powered by gpt-3.5-turbo, OpenAI’s most advanced language model.

Using the OpenAI API, you can build your own applications with gpt-3.5-turbo to do things like:
- Draft an email or other piece of writing
- Write Python code
- Answer questions about a set of documents
- Create conversational agents
- Give your software a natural language interface
- Tutor in a range of subjects
- Translate languages
- Simulate characters for video games and much more

This guide explains how to make an API call for chat-based language models and shares tips for getting good results.

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

#### Stream mode
```Pascal
OpenAI.Chat.CreateStream(
  procedure(Params: TChatParams)
  begin
    Params.Messages([TchatMessageBuild.User(Buf.Text)]);
    Params.MaxTokens(1024);
    Params.Stream;
  end,
  procedure(Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
  begin
    if (not IsDone) and Assigned(Chat) then
      Writeln(Chat.Choices[0].Delta.Content)
    else if IsDone then
      Writeln('DONE!');
    Writeln('-------');
    Sleep(100);
  end);
```

Review [Chat Documentation](https://platform.openai.com/docs/api-reference/chat) for more info.

### Images
Given a prompt and/or an input image, the model will generate a new image.

```Pascal
var Images := OpenAI.Image.Create(
  procedure(Params: TImageCreateParams)
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

Review [Images Documentation](https://platform.openai.com/docs/api-reference/images) for more info.

### Function Calling
In an API call, you can describe functions to gpt-3.5-turbo-0613 and gpt-4-0613, and have the model intelligently choose to output a JSON object containing arguments to call those functions. The Chat Completions API does not call the function; instead, the model generates JSON that you can use to call the function in your code.

The latest models (gpt-3.5-turbo-0613 and gpt-4-0613) have been fine-tuned to both detect when a function should to be called (depending on the input) and to respond with JSON that adheres to the function signature. With this capability also comes potential risks. We strongly recommend building in user confirmation flows before taking actions that impact the world on behalf of users (sending an email, posting something online, making a purchase, etc).

```Pascal
var Chat := OpenAI.Chat.Create(
  procedure(Params: TChatParams)
  begin
    Params.Functions(Funcs);  //list of functions (TArray<IChatFunction>)
    Params.FunctionCall(TFunctionCall.Auto);
    Params.Messages([TChatMessageBuild.User(Text)]);
    Params.MaxTokens(1024);
  end);
try
  for var Choice in Chat.Choices do
    if Choice.FinishReason = TFinishReason.FunctionCall then
      ProcFunction(Choice.Message.FunctionCall)  // execute function (send result to chat, and continue)
    else
      MemoChat.Lines.Add(Choice.Message.Content);
finally
  Chat.Free;
end;

...

procedure ProcFunction(Func: TChatFunctionCall);
begin
  var FuncResult := Execute(Func.Name, Func.Arguments);  //execute function and get result (json)
  var Chat := OpenAI.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Functions(Funcs);  //list of functions (TArray<IChatFunction>)
      Params.FunctionCall(TFunctionCall.Auto);
      Params.Messages([  //need all history
         TChatMessageBuild.User(Text), 
         TChatMessageBuild.NewAsistantFunc(Func.Name, Func.Arguments), 
         TChatMessageBuild.Func(FuncResult, Func.Name)]);
      Params.MaxTokens(1024);
    end);
  try
    for var Choice in Chat.Choices do
      MemoChat.Lines.Add(Choice.Message.Content);
  finally
    Chat.Free;
  end;
end;
```

Review [Functions Documentation](https://platform.openai.com/docs/guides/gpt/function-calling) for more info.

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
<img src="https://github.com/HemulGM/ChatGPT/raw/main/preview.png?raw=true" width="100%">

[ChatGPT (FMX)](https://github.com/HemulGM/ChatGPT)

## Requirements
This library does not require any 3rd party library. It works on recent Delphi versions (10.3+). Althought not fully tested, it should also work on all supported platforms (Windows, Linux, macOS, Android, iOS).

Since the library requires your secret API key, it's not recommended you use it on client applications, as your secret key will be exposed, unless you are sure about the security risks.

## Links

- [OpenAI Documentation](https://platform.openai.com/docs/introduction)
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


<hr>
<p align="center">
<img src="https://dtffvb2501i0o.cloudfront.net/images/logos/delphi-logo-128.webp" alt="Delphi">
</p>
<h5 align="center">
Made with :heart: on Delphi
</h5>

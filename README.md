# Delphi OpenAI API
![GitHub](https://img.shields.io/github/license/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/github/last-commit/hemulgm/DelphiOpenAI)
![GitHub](https://img.shields.io/badge/coverage-100%25-green)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.4+-yellow)

The library provides access to the API of the [OpenAI service](https://openai.com/api/), on the basis of which [ChatGPT](https://openai.com/blog/chatgpt) works and, for example, the generation of images from text using DALL-E.
Delphi 10.4+ is required to work with the library. It is possible to build under 10.3.
This library is a TOpenAI class for the main TComponent for more convenient work.

*This is an unofficial library. OpenAI does not provide any official library for Delphi.*

**Coverage**

<img src="https://github.com/HemulGM/ChatGPT.API/blob/main/OpenAL-GPT3.png?raw=true" height="150" align="right">

|API|Status|
|---|---|
|Models|🟢 Done|
|Completions|🟢 Done|
|Edits|🟢 Done|
|Images|🟢 Done|
|Embeddings|🟢 Done|
|Files|🟢 Done|
|Fine-tunes|🟢 Done|
|Moderations|🟢 Done|
|Engines (Depricated)|🟢 Done|

# Installation

To use the library, just add the root folder to the IDE library path, or your project source path.

# Usage

**Initialization**

```Pascal
uses OpenAI;

var OpenAI := TOpenAI.Create(Self, API_TOKEN);
```

**Models**
```Pascal
var Models := OpenAI.Model.List();
```

# Examples

**Completaions (for chat)**
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
  on E: OpenAIException do
    ShowError('OpenAI Error: ' + E.Message);
end;
```

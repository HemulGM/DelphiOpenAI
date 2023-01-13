# Delphi OpenAI API

<img src="https://github.com/HemulGM/ChatGPT.API/blob/main/OpenAL-GPT3.png?raw=true" height="150" align="right">

|API|Status|
|---|---|
|Models|🟢 Done|
|Completions|🟢 Done|
|Edits|🟢 Done|
|Images|🟢 Done|
|Embeddings|🟢 Done|
|Files|🟡 Working|
|Fine-tunes|🟡 Working|
|Moderations|🟢 Done|
|Engines (Depricated)|🟢 Done|

**Initialization**

```Pascal
var OpenAI := TOpenAI.Create(Self, API_TOKEN);
```

**Models**
```Pascal
var Models := OpenAI.Model.List();
```

**Completaions**
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

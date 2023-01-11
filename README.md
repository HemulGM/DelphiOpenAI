# Delphi GPT API

<img src="https://github.com/HemulGM/ChatGPT.API/blob/main/OpenAL-GPT3.png?raw=true" height="200" align="right">

|API|Status|
|---|---|
|Models|🟢 Done|
|Completions|🟢 Done|
|Edits|🟢 Done|
|Images|🟡 Working|
|Embeddings|🟢 Done|
|Files|🔴 None|
|Fine-tunes|🔴 None|
|Moderations|🔴 None|
|Engines|🔴 None|
|Parameter details|🔴 None|

**Initialization**

```Pascal
  FGPT := TGPTChatAPI.Create(Self, API_TOKEN);
```

**Completaions**
```Pascal
var Completions := FGPT.Completions(
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
var Images := FGPT.ImageGeneration(
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
  var Images := FGPT.ImageGeneration(...);
except
  on E: GPTException do
    ShowError('GPTError: ' + E.Message);
end;
```

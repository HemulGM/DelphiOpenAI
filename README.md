# ChatGPT.API
 Delphi GPT API

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
    Params.ResponseFormat('b64_json');
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

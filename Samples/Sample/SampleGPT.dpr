program SampleGPT;

uses
  System.SysUtils,
  OpenAI,
  OpenAI.GigaChat;

procedure OpenAI;
begin
  var client := TOpenAI.Create('<token>');
  var response := client.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          TChatMessageUser.Create.Content('Write a one-sentence story about numbers.')
          ]);
    end);
  print(response.Choices[0].Message.Content);
end;

procedure DeepSeek;
begin
  var client := TOpenAI.Create(
      'https://api.deepseek.com',
      '<token>');
  var response := client.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
          TChatMessageUser.Create.Content('Write a one-sentence story about numbers.')
          ]);
    end);
  print(response.Choices[0].Message.Content);
end;

procedure YandexGPT_ApiKey;
begin
  var client := TOpenAI.Create(
      'https://llm.api.cloud.yandex.net/v1',
      'api-key <token>');
  client.DisableBearerPrefix := True;
  var response := client.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt://b1gclqm3lu4itq271tvj/yandexgpt/latest');
      Params.Messages([
          TChatMessageUser.Create.Content('Write a one-sentence story about numbers.')
          ]);
    end);
  print(response.Choices[0].Message.Content);
end;

procedure YandexGPT;
begin
  var client := TOpenAI.Create(
      'https://llm.api.cloud.yandex.net/v1',
      '<token>');
  var response := client.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt://b1gclqm3lu4itq271tvj/yandexgpt/latest');
      Params.Messages([
          TChatMessageUser.Create.Content('Write a one-sentence story about numbers.')
          ]);
    end);
  print(response.Choices[0].Message.Content);
end;

procedure Qwen;
begin
  var client := TOpenAI.Create(
      'https://api.aimlapi.com/v1',
      '<token>');
  var response := client.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          TChatMessageUser.Create.Content('Write a one-sentence story about numbers.')
          ]);
    end);
  print(response.Choices[0].Message.Content);
end;

procedure GigaChat;
begin
  var client := TOpenAI.Create(
      'https://gigachat.devices.sberbank.ru/api/v1', '');
  client.Prepare := TApiPrepareGigaChat.Create(
      '<client_id>',
      '<auth_key>');
  var response := client.Chat.Create(
    procedure(Params: TChatParams)
    begin
      Params.Model('GigaChat');
      Params.Messages([
          TChatMessageUser.Create.Content('Write a one-sentence story about numbers.')
          ]);
    end);
  print(response.Choices[0].Message.Content);
end;

begin
  try
    //OpenAI;
    //YandexGPT_ApiKey;
    //YandexGPT;
    //Qwen;
    //DeepSeek;
    //GigaChat;
  except
    on E: Exception do
      Writeln(E.Message);
  end;
  readln;
end.


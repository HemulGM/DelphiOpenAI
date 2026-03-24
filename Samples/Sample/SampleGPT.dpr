program SampleGPT;

uses
  System.SysUtils,
  OpenAI;

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

begin
  try
    //OpenAI;
  except
    on E: Exception do
      Writeln(E.Message);
  end;
  readln;
end.

unit OpenAI.Component.Reg;

interface

uses
  OpenAI, OpenAI.Component.Chat, OpenAI.Component.Functions, OpenAI.Component.ChatHistory;

procedure Register;

implementation

uses
  System.Classes;

procedure Register;
begin
  RegisterComponents('OpenAI', [TOpenAIClient]);
  RegisterComponents('OpenAI', [TOpenAIChat]);
  RegisterComponents('OpenAI', [TOpenAIChatFunctions]);
  RegisterComponents('OpenAI', [TOpenAIChatHistory]);
end;

end.


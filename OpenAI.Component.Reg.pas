unit OpenAI.Component.Reg;

interface

uses
  OpenAI, OpenAI.Component.Chat, OpenAI.Component.Functions;

procedure Register;

implementation

uses
  System.Classes;

procedure Register;
begin
  RegisterComponents('OpenAI', [TOpenAIClient]);
  RegisterComponents('OpenAI', [TOpenAIChat]);
  RegisterComponents('OpenAI', [TOpenAIChatFunctions]);
end;

end.


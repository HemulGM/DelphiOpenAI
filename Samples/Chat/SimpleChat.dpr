program SimpleChat;

uses
  System.StartUpCopy,
  FMX.Forms,
  Chat.Main in 'Chat.Main.pas' {FormChat},
  OpenAI.API.Params in '..\..\OpenAI.API.Params.pas',
  OpenAI.API in '..\..\OpenAI.API.pas',
  OpenAI.Audio in '..\..\OpenAI.Audio.pas',
  OpenAI.Chat.Functions in '..\..\OpenAI.Chat.Functions.pas',
  OpenAI.Chat.Functions.Samples in '..\..\OpenAI.Chat.Functions.Samples.pas',
  OpenAI.Chat in '..\..\OpenAI.Chat.pas',
  OpenAI.Completions in '..\..\OpenAI.Completions.pas',
  OpenAI.Component.Chat in '..\..\OpenAI.Component.Chat.pas',
  OpenAI.Edits in '..\..\OpenAI.Edits.pas',
  OpenAI.Embeddings in '..\..\OpenAI.Embeddings.pas',
  OpenAI.Engines in '..\..\OpenAI.Engines.pas',
  OpenAI.Errors in '..\..\OpenAI.Errors.pas',
  OpenAI.Files in '..\..\OpenAI.Files.pas',
  OpenAI.FineTunes in '..\..\OpenAI.FineTunes.pas',
  OpenAI.FineTuning in '..\..\OpenAI.FineTuning.pas',
  OpenAI.Images in '..\..\OpenAI.Images.pas',
  OpenAI.Models in '..\..\OpenAI.Models.pas',
  OpenAI.Moderations in '..\..\OpenAI.Moderations.pas',
  OpenAI in '..\..\OpenAI.pas',
  OpenAI.Utils.ChatHistory in '..\..\OpenAI.Utils.ChatHistory.pas',
  OpenAI.Component.Functions in '..\..\OpenAI.Component.Functions.pas',
  OpenAI.Assistants in '..\..\OpenAI.Assistants.pas',
  OpenAI.Types in '..\..\OpenAI.Types.pas',
  OpenAI.Utils.ObjectHolder in '..\..\OpenAI.Utils.ObjectHolder.pas',
  OpenAI.Utils.Base64 in '..\..\OpenAI.Utils.Base64.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormChat, FormChat);
  Application.Run;
end.

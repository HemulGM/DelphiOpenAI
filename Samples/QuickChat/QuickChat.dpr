uses OpenAI;

begin
  repeat print('GPT: ' + chat('token', input('You: '))) until False;
end.

uses OpenAI;

begin
  repeat print('GPT: ' + chat('insert token', input('You: '))) until False;
end.

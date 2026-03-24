# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Delphi wrapper library for the OpenAI API. Pure Delphi implementation with no third-party dependencies—only requires RTL and RESTComponents. Compatible with OpenAI, Azure OpenAI, DeepSeek, YandexGPT, Qwen, and GigaChat backends.

## Build

This is a Delphi component package (`OpenAIPackage.dpk` / `OpenAIPackage.dproj`). Build with MSBuild or the Delphi IDE (Delphi 11+).

```
msbuild OpenAIPackage.dproj
```

Sample applications are in `Samples/` with a group project at `Samples/OpenAIGroup.groupproj`.

There are no automated tests, CI pipelines, or lint tools configured.

## Architecture

### Route Pattern

Each OpenAI API endpoint group is a route class inheriting from `TOpenAIAPIRoute` (defined in `OpenAI.API.pas`). Routes handle HTTP calls via the base class and deserialize JSON responses using `REST.Json` RTTI.

```
TOpenAIAPIRoute (abstract base — OpenAI.API.pas)
├── TChatRoute          (OpenAI.Chat.pas)
├── TCompletionsRoute   (OpenAI.Completions.pas)
├── TImagesRoute        (OpenAI.Images.pas)
├── TModelsRoute        (OpenAI.Models.pas)
├── TEmbeddingsRoute    (OpenAI.Embeddings.pas)
├── TModerationsRoute   (OpenAI.Moderations.pas)
├── TAudioRoute         (OpenAI.Audio.pas)
├── TFilesRoute         (OpenAI.Files.pas)
├── TFineTuningRoute    (OpenAI.FineTuning.pas)
├── TAssistantsRoute    (OpenAI.Assistants.pas)
└── ... (Edits, Engines, FineTunes — legacy)
```

### Entry Points

- **`TOpenAI`** (`OpenAI.pas`) — Main class implementing `IOpenAI`. Lazily creates route instances via property getters (e.g., `OpenAI.Chat`, `OpenAI.Images`).
- **`TOpenAIComponent`** / **`TOpenAIClient`** (`OpenAI.pas`) — VCL/FMX component wrapper around `TOpenAI` for IDE drag-and-drop use. Registered in `OpenAI.Component.Reg.pas`.
- **`TOpenAIChat`** (`OpenAI.Component.Chat.pas`) — Async chat component with `ITask`-based threading and optional `Synchronize` support.

### Fluent Parameter Builders

All API parameters use `TJSONParam` (`OpenAI.API.Params.pas`) as a base class. Concrete param classes (e.g., `TChatParams`, `TImageCreateParams`) return `Self` from setter methods to enable method chaining:

```pascal
OpenAI.Chat.Create(
  procedure(Params: TChatParams)
  begin
    Params.Model('gpt-4').MaxTokens(1024).Stream;
  end);
```

### HTTP Layer

`TOpenAIAPI` (`OpenAI.API.pas`) manages all HTTP communication using `System.Net.HttpClient`. Supports:
- Streaming via SSE with callback handlers
- Azure endpoint configuration (deployment name, API version)
- Proxy settings, custom headers, configurable timeouts
- Custom exception hierarchy: `OpenAIException`, `OpenAIExceptionAPI`, `OpenAIExceptionRateLimitError`, etc.

### Key Utilities

- `OpenAI.Utils.ChatHistory.pas` — Chat message history manager with token-based truncation
- `OpenAI.Utils.JSON.Cleaner.pas` — Cleans malformed JSON from API responses
- `OpenAI.Utils.Base64.pas` — Base64 encoding for image inputs
- `OpenAI.Chat.Functions.pas` — `IChatFunction` interface for function-calling; sample implementations in `OpenAI.Chat.Functions.Samples.pas`

### Conventions

- All library units are prefixed `OpenAI.` and live in the repository root (no `src/` directory).
- Response objects containing `TArray<T>` are owned by the caller and must be freed.
- Enum helpers (e.g., `TMessageRoleHelper`, `TFinishReasonHelper`) handle string-to-enum conversion for API values.

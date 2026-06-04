# FANLIVE AI Proxy

Backend scaffold for a future FANLIVE AI fan chat proxy.

This service can run in two modes:

- Without `OPENAI_API_KEY`: returns a local mock response.
- With `OPENAI_API_KEY`: calls the OpenAI Responses API from the backend, validates the JSON output, and falls back to the mock response if anything fails.

## Install

```bash
npm install
```

## Run Locally

```bash
npm start
```

By default, the server listens on port `3000`.

```bash
POST http://localhost:3000/fan-reaction
```

## Optional OpenAI Mode

Set `OPENAI_API_KEY` in the server environment before starting the proxy:

```bash
OPENAI_API_KEY=your_key_here npm start
```

On Windows PowerShell:

```powershell
$env:OPENAI_API_KEY="your_key_here"
npm start
```

The key stays on the backend. Flutter should call this proxy and should never receive or store `OPENAI_API_KEY`.

## Request Shape

Flutter will later send the same fields used by `AiFanRequest`:

```json
{
  "text": "안녕",
  "stageName": "FANLIVE",
  "fandomName": "팬덤",
  "themeTitle": "첫 방송",
  "recentComments": [],
  "fanAffection": {
    "하루": 10,
    "별밤": 8,
    "민트": 12
  }
}
```

## Response Shape

```json
{
  "comments": ["하루: FANLIVE 말 듣고 바로 왔어요"],
  "viewerDelta": 8,
  "heartDelta": 20
}
```

## OpenAI Integration

Flutter will later call this backend instead of calling OpenAI directly. The backend reads `OPENAI_API_KEY` from the server environment, calls the OpenAI Responses API, validates the model output, and returns the same response shape to Flutter.

Keep API keys only on the backend. Do not ship `OPENAI_API_KEY` in the Flutter app.

If OpenAI is unavailable, the API key is missing, the model returns invalid JSON, or the request fails, the proxy returns the mock response.

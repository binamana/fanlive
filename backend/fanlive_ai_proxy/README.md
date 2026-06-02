# FANLIVE AI Proxy

Backend scaffold for a future FANLIVE AI fan chat proxy.

This service is intentionally mocked for now. It does not call OpenAI and does not require an API key to run locally.

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

## Future OpenAI Integration

Later, Flutter should call this backend instead of calling OpenAI directly. The backend will read `OPENAI_API_KEY` from the server environment, call the OpenAI Responses API, validate the model output, and return the same response shape to Flutter.

Keep API keys only on the backend. Do not ship `OPENAI_API_KEY` in the Flutter app.

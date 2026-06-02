const express = require('express');

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(express.json({ limit: '1mb' }));

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.post('/fan-reaction', (req, res) => {
  const request = normalizeFanRequest(req.body);

  // TODO: Call a backend-owned OpenAI Responses API integration here.
  // TODO: Keep OPENAI_API_KEY on the server and never expose it to Flutter.
  // TODO: Validate the AI output before returning it to the app.
  const response = createMockFanReaction(request);

  res.json(response);
});

function normalizeFanRequest(body) {
  return {
    text: toStringValue(body?.text),
    stageName: toStringValue(body?.stageName),
    fandomName: toStringValue(body?.fandomName),
    themeTitle: toStringValue(body?.themeTitle),
    recentComments: Array.isArray(body?.recentComments)
      ? body.recentComments.map(toStringValue).slice(-10)
      : [],
    fanAffection: isPlainObject(body?.fanAffection) ? body.fanAffection : {},
  };
}

function createMockFanReaction(request) {
  const themePrefix = request.themeTitle ? `${request.themeTitle} 분위기` : '오늘 분위기';
  const stageName = request.stageName || 'FANLIVE';
  const fandomName = request.fandomName || '팬덤';

  return {
    comments: [
      `하루: ${stageName} 말 듣고 바로 마음이 따뜻해졌어요`,
      `별밤: ${themePrefix}에 맞게 천천히 이어가도 좋아요`,
      `민트: ${fandomName} 채팅창 하트 준비 완료 💖`,
    ],
    viewerDelta: 8,
    heartDelta: 24,
  };
}

function toStringValue(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

app.listen(port, () => {
  console.log(`FANLIVE AI proxy listening on port ${port}`);
});

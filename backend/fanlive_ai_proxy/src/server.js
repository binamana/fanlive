const express = require('express');
const OpenAI = require('openai');

const app = express();
const port = Number(process.env.PORT || 3000);
const openaiApiKey = process.env.OPENAI_API_KEY;
const openaiClient = openaiApiKey ? new OpenAI({ apiKey: openaiApiKey }) : null;
const openaiModel = 'gpt-4.1-mini';

app.use(express.json({ limit: '1mb' }));
app.use((req, res, next) => {
  const origin = req.headers.origin;

  if (
    typeof origin === 'string' &&
    (origin.startsWith('http://localhost') ||
      origin.startsWith('http://127.0.0.1'))
  ) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }

  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.sendStatus(204);
    return;
  }

  next();
});

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.post('/fan-reaction', async (req, res) => {
  const request = normalizeFanRequest(req.body);
  console.log(
    `[fan-reaction] request timestamp=${new Date().toISOString()} textLength=${request.text.length} textPreview="${sanitizeLogPreview(request.text)}" stageName="${request.stageName}" themeTitle="${request.themeTitle}" recentComments=${request.recentComments.length}`,
  );
  const openaiResponse = await createOpenAIFanReaction(request);

  if (openaiResponse) {
    console.log('[fan-reaction] OpenAI response used');
    res.json(openaiResponse);
    return;
  }

  console.log('[fan-reaction] mock fallback used');
  res.json(createMockFanReaction(request));
});

function normalizeFanRequest(body) {
  return {
    text: toStringValue(body?.text),
    stageName: toStringValue(body?.stageName),
    fandomName: toStringValue(body?.fandomName),
    themeTitle: toStringValue(body?.themeTitle),
    sessionMemory: toStringValue(body?.sessionMemory),
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

async function createOpenAIFanReaction(request) {
  if (!openaiClient) {
    return null;
  }

  try {
    const response = await openaiClient.responses.create({
      model: openaiModel,
      instructions: [
        'You write FANLIVE Korean live chat reactions from fans who just heard the streamer speak.',
        'Return strict JSON only. Do not include markdown, code fences, explanations, or extra text.',
        'The JSON must contain comments, viewerDelta, and heartDelta.',
        'comments must be exactly 3 short Korean strings, one each from 하루, 별밤, and 민트.',
        'Every comment must directly react to the latest user text field. Mention, paraphrase, or emotionally answer something specific from that text.',
        'Use themeTitle to match the broadcast mood, but do not force it if the user text is more important.',
        'Use sessionMemory to resolve vague follow-ups like "내일도 걱정돼", "그게 좀 신경 쓰여", or "그래도 좀 낫다".',
        'LATEST_USER_TEXT is still highest priority, but SESSION_MEMORY explains what vague words refer to.',
        'Use recentComments to avoid repeating the same phrase, emotion, or rhythm.',
        'Use fanAffection: high-affection fans can sound more familiar, warm, and teasing; low-affection fans should be supportive but less intimate.',
        'Fan voices: 하루 is emotionally sensitive, caring, and slightly worried; 하루 notices feelings behind the words.',
        'Fan voices: 별밤 is calm, observant, and realistic; 별밤 gives grounded live-chat perspective.',
        'Fan voices: 민트 is playful, fast-chat style, lightly funny, and heart-heavy.',
        'At least one comment should ask a natural follow-up or invite the streamer to keep talking.',
        'Do not sound like an assistant, counselor, brand copy, or polished marketing text. Sound like Korean live chat fans.',
        'Good example for text "오늘 너무 피곤해": "하루: 목소리도 좀 지친 것 같아서 걱정돼요 ㅠㅠ", "별밤: 오늘은 텐션 낮아도 괜찮아요, 천천히 해요", "민트: 피곤하면 물 한입 가자... 채팅창이 지켜봄 💖"',
        'Bad example: "하루: 오늘 방송 분위기 좋아요", because it ignores the user text and feels generic.',
      ].join(' '),
      input: buildFanReactionInput(request),
      max_output_tokens: 900,
      text: {
        verbosity: 'medium',
        format: {
          type: 'json_schema',
          name: 'fan_reaction_response',
          strict: true,
          schema: {
            type: 'object',
            additionalProperties: false,
            required: ['comments', 'viewerDelta', 'heartDelta'],
            properties: {
              comments: {
                type: 'array',
                items: { type: 'string' },
              },
              viewerDelta: { type: 'number' },
              heartDelta: { type: 'number' },
            },
          },
        },
      },
    });

    const responseText = extractResponseText(response);

    if (!responseText) {
      console.warn(
        `[fan-reaction] OpenAI output had no text/json content; shape=${summarizeResponseShape(response)}`,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(responseText);
    } catch (parseError) {
      console.warn(
        `[fan-reaction] OpenAI JSON parse failed: ${parseError.message}; shape=${summarizeResponseShape(response)}`,
      );
      return null;
    }

    const validatedResponse = validateFanReactionResponse(parsed);

    if (!validatedResponse) {
      console.warn(
        `[fan-reaction] OpenAI output failed validation; shape=${summarizeResponseShape(response)}`,
      );
      return null;
    }

    console.log(
      `[fan-reaction] validated comments=${JSON.stringify(validatedResponse.comments)}`,
    );
    return validatedResponse;
  } catch (error) {
    console.warn(`[fan-reaction] OpenAI fallback reason: ${error.message}`);
    return null;
  }
}

function buildFanReactionInput(request) {
  const recentComments = request.recentComments.length
    ? request.recentComments
        .map((comment, index) => `${index + 1}. ${comment}`)
        .join('\n')
    : '(none)';
  const fanAffection = Object.keys(request.fanAffection).length
    ? JSON.stringify(request.fanAffection)
    : '(none)';
  const sessionMemory = request.sessionMemory || '(empty)';

  return [
    'FANLIVE_AI_FAN_REACTION_REQUEST',
    '',
    'Core priority rules:',
    '1. LATEST_USER_TEXT is the highest priority. Read it first and answer it directly.',
    '2. Every fan comment must respond to a specific detail, phrase, feeling, or situation in LATEST_USER_TEXT.',
    '3. Do not only react to THEME_TITLE. Theme is mood only.',
    '4. Do not only give generic encouragement. If encouraging, name the exact reason from LATEST_USER_TEXT.',
    '5. SESSION_MEMORY is supporting context only. Use it to resolve vague follow-ups like "내일도 걱정돼", "그게 좀 신경 쓰여", or "그래도 좀 낫다".',
    '5a. LATEST_USER_TEXT is still highest priority, but SESSION_MEMORY explains what vague words refer to.',
    '6. If LATEST_USER_TEXT mentions a concrete situation, each comment should reflect that situation.',
    '7. If LATEST_USER_TEXT is vague, ask a natural short follow-up.',
    '8. At least one of the three comments must ask a short follow-up question.',
    '9. Avoid generic comments like "오늘 분위기 좋아요", "응원할게요", or "힘내요" unless tied to the exact user text.',
    '',
    `LATEST_USER_TEXT: ${request.text || '(empty)'}`,
    `STAGE_NAME: ${request.stageName || '(empty)'}`,
    `FANDOM_NAME: ${request.fandomName || '(empty)'}`,
    `THEME_TITLE: ${request.themeTitle || '(empty)'}`,
    `SESSION_MEMORY: ${sessionMemory}`,
    'RECENT_COMMENTS:',
    recentComments,
    `FAN_AFFECTION: ${fanAffection}`,
    '',
    'Return strict JSON matching the schema. Korean only. Exactly 3 comments: 하루, 별밤, 민트.',
  ].join('\n');
}

function extractResponseText(response) {
  if (typeof response?.output_text === 'string' && response.output_text.trim()) {
    return response.output_text.trim();
  }

  if (!Array.isArray(response?.output)) {
    return null;
  }

  for (const outputItem of response.output) {
    if (!Array.isArray(outputItem?.content)) {
      continue;
    }

    for (const contentPart of outputItem.content) {
      if (typeof contentPart?.text === 'string' && contentPart.text.trim()) {
        return contentPart.text.trim();
      }

      if (contentPart?.json !== undefined) {
        return typeof contentPart.json === 'string'
          ? contentPart.json.trim()
          : JSON.stringify(contentPart.json);
      }
    }
  }

  return null;
}

function validateFanReactionResponse(value) {
  if (!isPlainObject(value)) {
    return null;
  }

  const { comments, viewerDelta, heartDelta } = value;

  if (!Array.isArray(comments) || comments.length !== 3) {
    return null;
  }

  if (!comments.every((comment) => typeof comment === 'string' && comment.trim())) {
    return null;
  }

  if (
    !Number.isFinite(viewerDelta) ||
    !Number.isFinite(heartDelta) ||
    viewerDelta < 0 ||
    heartDelta < 0
  ) {
    return null;
  }

  return {
    comments: comments.map((comment) => comment.trim()),
    viewerDelta: Math.trunc(viewerDelta),
    heartDelta: Math.trunc(heartDelta),
  };
}

function summarizeResponseShape(response) {
  const output = Array.isArray(response?.output) ? response.output : [];
  const outputSummary = output.map((outputItem) => {
    const content = Array.isArray(outputItem?.content) ? outputItem.content : [];

    return {
      type: outputItem?.type || null,
      contentCount: content.length,
      content: content.map((contentPart) => ({
        type: contentPart?.type || null,
        hasText: typeof contentPart?.text === 'string',
        textLength:
          typeof contentPart?.text === 'string' ? contentPart.text.length : 0,
        hasJson: contentPart?.json !== undefined,
      })),
    };
  });

  return JSON.stringify({
    hasOutputText: typeof response?.output_text === 'string',
    outputTextLength:
      typeof response?.output_text === 'string' ? response.output_text.length : 0,
    outputCount: output.length,
    output: outputSummary,
  });
}

function toStringValue(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function sanitizeLogPreview(value) {
  return toStringValue(value)
    .replace(/[\r\n\t]/g, ' ')
    .replace(/\s+/g, ' ')
    .slice(0, 40);
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

app.listen(port, () => {
  console.log(`FANLIVE AI proxy listening on port ${port}`);
});

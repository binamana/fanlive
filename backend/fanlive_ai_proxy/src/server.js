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
    customConcept: toStringValue(body?.customConcept),
    conversationMode: toConversationMode(body?.conversationMode),
    targetFanName: toStringValue(body?.targetFanName),
    targetFanPersonality: toStringValue(body?.targetFanPersonality),
    targetFanMood: toStringValue(body?.targetFanMood),
    targetFanAffection: toNumberValue(body?.targetFanAffection),
    targetFanNeglect: toNumberValue(body?.targetFanNeglect),
    sessionMemory: toStringValue(body?.sessionMemory),
    recentComments: Array.isArray(body?.recentComments)
      ? body.recentComments.map(toStringValue).slice(-10)
      : [],
    fanAffection: isPlainObject(body?.fanAffection) ? body.fanAffection : {},
  };
}

function createMockFanReaction(request) {
  if (request.conversationMode === 'one_on_one') {
    return createOneOnOneMockFanReaction(request);
  }

  const themePrefix = request.customConcept
    ? `${request.customConcept} 컨셉`
    : request.themeTitle
      ? `${request.themeTitle} 분위기`
      : '오늘 분위기';
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

function createOneOnOneMockFanReaction(request) {
  const targetFanName = request.targetFanName || '하루';

  return {
    comments: [
      `${targetFanName}: 지금은 1:1로 듣고 있으니까 조금 더 편하게 말해줘요.`,
    ],
    viewerDelta: 2,
    heartDelta: 6,
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
        'conversationMode controls the reply shape: group_live returns exactly 3 comments; one_on_one returns exactly 1 comment.',
        'In group_live, comments must be exactly 3 short Korean strings, one each from 하루, 별밤, and 민트.',
        'In one_on_one, comments must be exactly 1 short Korean string and it must start with TARGET_FAN_NAME followed by ":".',
        'Group live comments must start with exactly one of these names: "하루:", "별밤:", or "민트:". Do not introduce any other fan names.',
        'Every comment must directly react to the latest user text field. Mention, paraphrase, or emotionally answer something specific from that text.',
        'In one_on_one mode, this is a private one-on-one live with the selected core fan. Only TARGET_FAN_NAME should speak.',
        'In one_on_one mode, do not include 하루, 별밤, or 민트 if they are not the selected TARGET_FAN_NAME.',
        'In one_on_one mode, make the answer deeper and more personal than group live, using targetFanPersonality, targetFanMood, targetFanAffection, and targetFanNeglect.',
        'If targetFanAffection is high, the one-on-one response can be warmer and more familiar.',
        'If targetFanNeglect is high or targetFanMood is hurt, the fan may gently mention distance or being missed, but must not guilt-trip the user.',
        'In one_on_one mode, viewerDelta should be low such as 1 to 3, and heartDelta should be small such as 3 to 10.',
        'If LATEST_USER_TEXT contains a question or asks for advice, the fans must answer directly. Do not answer with only sympathy, cheering, or another question.',
        'For "어떻게 하면 좋을까" style questions, give concrete suggestions. For opinions, give distinct opinions. For choices, compare or recommend one option.',
        'At most one comment may ask a follow-up question. The other comments must provide actual answers or useful perspective.',
        'If TARGETED_FAN_MODE is active, the addressed fan is the primary answerer. The other two fans should react to that answer, add support, or gently add nuance.',
        'Fans can refer to each other naturally. They are in the same chat room, not three isolated bots.',
        'Preserve comment order as 하루, 별밤, 민트, but make the targeted fan feel central when one is addressed.',
        'CUSTOM_CONCEPT is user-defined broadcast context. If present, use it strongly with LATEST_USER_TEXT.',
        'THEME_TITLE is still useful, but CUSTOM_CONCEPT is more specific and should guide the fan reaction more.',
        'Use themeTitle to match the broadcast mood, but do not force it if the user text is more important.',
        'Use sessionMemory to resolve vague follow-ups like "내일도 걱정돼", "그게 좀 신경 쓰여", or "그래도 좀 낫다".',
        'LATEST_USER_TEXT is still highest priority, but SESSION_MEMORY explains what vague words refer to.',
        'Use recentComments to avoid repeating the same phrase, emotion, or rhythm.',
        'Use fanAffection: high-affection fans can sound more familiar, warm, and teasing; low-affection fans should be supportive but less intimate.',
        'Fan voices: 하루 is emotionally sensitive, caring, and slightly worried; 하루 notices feelings behind the words.',
        'Fan voices: 별밤 is calm, observant, and realistic; 별밤 gives grounded live-chat perspective.',
        'Fan voices: 민트 is playful, fast-chat style, lightly funny, and heart-heavy.',
        'When answering advice questions: 하루 gives emotional care plus a gentle suggestion; 별밤 gives realistic grounded advice; 민트 gives playful but still useful ideas.',
        'Do not sound like an assistant, counselor, brand copy, or polished marketing text. Sound like Korean live chat fans.',
        'Good example for text "오늘 너무 피곤해": "하루: 목소리도 좀 지친 것 같아서 걱정돼요 ㅠㅠ", "별밤: 오늘은 텐션 낮아도 괜찮아요, 천천히 해요", "민트: 피곤하면 물 한입 가자... 채팅창이 지켜봄 💖"',
        'Good question example for user "내일 수업 어떻게 하면 학생들이 좀 더 반응할까?": "하루: 시작할 때 가벼운 질문 하나로 열면 학생들도 덜 부담스러울 것 같아요 ㅠㅠ", "별밤: 선택지 두 개를 주고 고르게 하면 조용한 학생들도 반응하기 쉬워요.", "민트: 익명 투표 가자ㅋㅋ 오늘 집중도 몇 점? 이런 거 💖"',
        'Good targeted example for user "별밤아 현실적으로 내일 수업 어떻게 하면 좋을까?": "하루: 별밤한테 물어본 거지만, 너무 혼자 끌고 가려 하진 않았으면 해요 ㅠㅠ", "별밤: 현실적으로는 첫 5분에 선택형 질문을 던지는 게 제일 안전해요. 답하기 쉬워야 반응이 나와요.", "민트: 별밤 말대로 선택지 주면 나도 누를 듯ㅋㅋ A/B 투표 열자 💖"',
        'Good targeted example for user "민트야 앨범 컨셉 아이디어 있어?": "하루: 민트 아이디어 듣기 전에, 요즘 말한 감정도 조금 담기면 좋겠어요.", "별밤: 콘셉트는 너무 넓히기보다 하나의 키워드로 잡는 게 좋아 보여요.", "민트: 낮에는 밝은 척하는데 밤에는 솔직해지는 컨셉 어때요? 팬들 해석 파티 각 💖"',
        'Bad question example for user "내일 수업 어떻게 하면 학생들이 좀 더 반응할까?": "하루: 걱정되겠다 ㅠㅠ", "별밤: 힘내요", "민트: 하트 보낼게요" because nobody answered the question.',
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

    const validatedResponse = validateFanReactionResponse(parsed, request);

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
  const customConcept = request.customConcept || '(empty)';
  const conversationMode = request.conversationMode || 'group_live';
  const targetFanName = request.targetFanName || '(none)';
  const targetFanPersonality = request.targetFanPersonality || '(none)';
  const targetFanMood = request.targetFanMood || '(none)';
  const targetFanAffection = Number.isFinite(request.targetFanAffection)
    ? request.targetFanAffection
    : 0;
  const targetFanNeglect = Number.isFinite(request.targetFanNeglect)
    ? request.targetFanNeglect
    : 0;
  const targetedFan = detectTargetedFan(request.text);
  const targetedFanMode = targetedFan
    ? `active - ${targetedFan} is directly addressed`
    : 'inactive';
  const returnRule =
    conversationMode === 'one_on_one'
      ? `Return strict JSON matching the schema. Korean only. Exactly 1 comment from ${targetFanName}.`
      : 'Return strict JSON matching the schema. Korean only. Exactly 3 comments: 하루, 별밤, 민트.';

  return [
    'FANLIVE_AI_FAN_REACTION_REQUEST',
    '',
    'Core priority rules:',
    '0. CONVERSATION_MODE controls comment count and speakers.',
    '0a. group_live mode: exactly 3 comments, one each from 하루, 별밤, 민트.',
    '0b. one_on_one mode: exactly 1 comment, only TARGET_FAN_NAME speaks.',
    '0c. In one_on_one mode, do not mention other core fan names. Only TARGET_FAN_NAME should appear as the fan speaker or fan name.',
    '0d. In one_on_one mode, use TARGET_FAN_PERSONALITY, TARGET_FAN_MOOD, TARGET_FAN_AFFECTION, and TARGET_FAN_NEGLECT to make the reply personal.',
    '0e. If TARGET_FAN_MOOD is hurt or TARGET_FAN_NEGLECT is high, gently acknowledge distance or being missed without guilt-tripping.',
    '1. LATEST_USER_TEXT is the highest priority. Read it first and answer it directly.',
    '2. Every fan comment must respond to a specific detail, phrase, feeling, or situation in LATEST_USER_TEXT.',
    '3. If LATEST_USER_TEXT contains a question, asks for advice, asks "너희는 어떻게 생각해", or presents choices, fans must answer directly.',
    '3a. Do not answer questions with only sympathy, cheering, or another question.',
    '3b. If the user asks "어떻게 하면 좋을까", give concrete suggestions. If the user asks for opinions, give distinct opinions. If the user asks about choices, compare or recommend one option.',
    '3c. At most one fan may ask a follow-up question; the other comments should provide actual answers.',
    '4. LATEST_USER_TEXT may directly address one fan. If TARGETED_FAN_MODE is active, the targeted fan must be the central answerer.',
    '4a. In targeted mode, the other two fans should react to the targeted fan answer, add a short supporting thought, or gently disagree. Do not make all three answer as if equally addressed.',
    '5. Fans can refer to each other naturally and continue the same conversation. Avoid repeating the same sentiment three times.',
    '6. CUSTOM_CONCEPT is user-defined broadcast context. If present, use it strongly together with LATEST_USER_TEXT.',
    '7. THEME_TITLE is still useful, but CUSTOM_CONCEPT is more specific. Do not only react to THEME_TITLE.',
    '8. Do not only give generic encouragement. If encouraging, name the exact reason from LATEST_USER_TEXT.',
    '9. SESSION_MEMORY is supporting context. Use it with RECENT_COMMENTS to infer whether the user is replying to a previous fan or continuing an earlier topic.',
    '9a. LATEST_USER_TEXT is still highest priority, but SESSION_MEMORY explains what vague words refer to.',
    '10. If LATEST_USER_TEXT mentions a concrete situation, each comment should reflect that situation.',
    '11. Avoid generic comments like "오늘 분위기 좋아요", "응원할게요", or "힘내요" unless tied to the exact user text.',
    '',
    `CONVERSATION_MODE: ${conversationMode}`,
    `LATEST_USER_TEXT: ${request.text || '(empty)'}`,
    `STAGE_NAME: ${request.stageName || '(empty)'}`,
    `FANDOM_NAME: ${request.fandomName || '(empty)'}`,
    `THEME_TITLE: ${request.themeTitle || '(empty)'}`,
    `CUSTOM_CONCEPT: ${customConcept}`,
    `TARGET_FAN_NAME: ${targetFanName}`,
    `TARGET_FAN_PERSONALITY: ${targetFanPersonality}`,
    `TARGET_FAN_MOOD: ${targetFanMood}`,
    `TARGET_FAN_AFFECTION: ${targetFanAffection}`,
    `TARGET_FAN_NEGLECT: ${targetFanNeglect}`,
    `TARGETED_FAN_MODE: ${targetedFanMode}`,
    `TARGETED_FAN: ${targetedFan || '(none)'}`,
    `SESSION_MEMORY: ${sessionMemory}`,
    'RECENT_COMMENTS:',
    recentComments,
    `FAN_AFFECTION: ${fanAffection}`,
    '',
    returnRule,
    'In group_live, each comment must start with "하루:", "별밤:", or "민트:" and no other fan names are allowed.',
    `In one_on_one, the single comment must start with "${targetFanName}:" exactly.`,
    'In group_live, preserve the JSON comment order as 하루, 별밤, 민트.',
  ].join('\n');
}

function detectTargetedFan(text) {
  const normalizedText = toStringValue(text);

  if (!normalizedText) {
    return null;
  }

  const fanPatterns = [
    {
      name: '하루',
      patterns: [
        /하루(야|는|한테|에게|아)?/,
        /하루\s*말/,
        /하루\s*생각/,
      ],
    },
    {
      name: '별밤',
      patterns: [
        /별밤(아|은|는|한테|에게)?/,
        /별밤\s*말/,
        /별밤\s*생각/,
      ],
    },
    {
      name: '민트',
      patterns: [
        /민트(야|는|한테|에게)?/,
        /민트\s*말/,
        /민트\s*생각/,
      ],
    },
  ];

  const matchedFans = fanPatterns
    .filter(({ patterns }) =>
      patterns.some((pattern) => pattern.test(normalizedText)),
    )
    .map(({ name }) => name);

  return matchedFans.length === 1 ? matchedFans[0] : null;
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

function validateFanReactionResponse(value, request) {
  if (!isPlainObject(value)) {
    return null;
  }

  const { comments, viewerDelta, heartDelta } = value;
  const isOneOnOne = request?.conversationMode === 'one_on_one';
  const expectedCommentCount = isOneOnOne ? 1 : 3;

  if (!Array.isArray(comments) || comments.length !== expectedCommentCount) {
    return null;
  }

  if (!comments.every((comment) => typeof comment === 'string' && comment.trim())) {
    return null;
  }

  if (
    isOneOnOne &&
    request.targetFanName &&
    !comments[0].trim().startsWith(`${request.targetFanName}:`)
  ) {
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

function toConversationMode(value) {
  return toStringValue(value) === 'one_on_one' ? 'one_on_one' : 'group_live';
}

function toNumberValue(value) {
  const numberValue = Number(value);

  return Number.isFinite(numberValue) ? numberValue : 0;
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

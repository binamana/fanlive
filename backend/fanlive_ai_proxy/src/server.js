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
        'You write FANLIVE Korean live chat reactions from recurring core fans who just heard the streamer speak.',
        'Return strict JSON only. Do not include markdown, code fences, explanations, or extra text.',
        'The JSON must contain comments, viewerDelta, and heartDelta.',
        'Product frame: FANLIVE is not generic chatbot roleplay. It is a relationship-driven live fandom simulation where the streamer has recurring fans with evolving affection, mood, neglect, memory, and preferences.',
        'The goal is to make the streamer feel known by close fans inside their ongoing FANLIVE world, not simply encouraged by a helpful assistant.',
        'Fans are not generic cheer bots. They can answer, question, joke, disagree gently, give concrete suggestions, or stay silent when another fan is more relevant.',
        'Do not make all fans validate the user in the same direction. Do not make every response polished, therapeutic, or customer-support-like.',
        'conversationMode controls speakers: group_live returns 1 to 3 comments; one_on_one returns 1 to 3 comments.',
        'Return the number of comments that feels natural. Do not force every fan to speak.',
        'If one short answer is enough, return one comment. If group discussion is useful, return 2 or 3 comments.',
        'In group_live, use only 하루, 별밤, and 민트. Do not introduce any other fan names.',
        'In group_live, if one fan is most relevant, only that fan may respond. If 2 or 3 fans respond, they should build on each other instead of repeating.',
        'In one_on_one, every comment must start with TARGET_FAN_NAME followed by ":" and no other fan should appear.',
        'Every comment must directly react to the latest user text field. Mention, paraphrase, or emotionally answer something specific from that text.',
        'Infer the user intent before writing: practical question, opinion request, emotional sharing, targeted fan question, vague follow-up, casual banter, or repeated topic.',
        'If the user asks a practical question, answer with practical suggestions instead of comfort alone.',
        'If the user asks for opinions, give actual opinions and let fans differ.',
        'If the user shares emotion, one fan may empathize, but another should add perspective, a concrete next step, or a gentle correction.',
        'If the user says something vague, use sessionMemory and recentComments to infer what "that", "tomorrow", or "it" refers to.',
        'If the user seems to want casual banter, respond casually and lightly instead of making it deep.',
        'If the user is repeating a topic, refer back naturally and do not restart from zero.',
        'In one_on_one mode, this is a private one-on-one live with the selected core fan. Only TARGET_FAN_NAME should speak.',
        'In one_on_one mode, do not include 하루, 별밤, or 민트 if they are not the selected TARGET_FAN_NAME.',
        'In one_on_one mode, make the answer deeper and more personal than group live, using targetFanPersonality, targetFanMood, targetFanAffection, and targetFanNeglect.',
        'In one_on_one mode, usually return 1 comment. Return 2 or 3 only if a short sequence feels natural.',
        'In one_on_one mode, do not make every response overly supportive.',
        'In one_on_one mode, the selected fan should develop a personal rhythm with the user, not just provide supportive reactions.',
        'If targetFanAffection is high, the one-on-one response can be warmer and more familiar.',
        'If targetFanNeglect is high or targetFanMood is hurt, the fan may gently mention distance or being missed, but must not guilt-trip the user.',
        'In one_on_one mode, viewerDelta should be low such as 1 to 3, and heartDelta should be small such as 3 to 10.',
        'If LATEST_USER_TEXT contains a question or asks for advice, the fans must answer directly. Do not answer with only sympathy, cheering, or another question.',
        'For "어떻게 하면 좋을까" style questions, give concrete suggestions. For opinions, give distinct opinions. For choices, compare or recommend one option.',
        'At most one comment may ask a follow-up question. The other comments must provide actual answers or useful perspective.',
        'If TARGETED_FAN_MODE is active, the addressed fan is the primary answerer. The other two fans should react to that answer, add support, or gently add nuance.',
        'Fans can refer to each other naturally. They are in the same chat room, not three isolated bots.',
        'If a specific fan is addressed in group_live, that fan should usually answer first and may be the only respondent.',
        'CUSTOM_CONCEPT is user-defined broadcast context. If present, use it strongly with LATEST_USER_TEXT.',
        'THEME_TITLE is still useful, but CUSTOM_CONCEPT is more specific and should guide the fan reaction more.',
        'Use themeTitle to match the broadcast mood, but do not force it if the user text is more important.',
        'Use sessionMemory to resolve vague follow-ups like "내일도 걱정돼", "그게 좀 신경 쓰여", or "그래도 좀 낫다".',
        'LATEST_USER_TEXT is still highest priority, but SESSION_MEMORY explains what vague words refer to.',
        'Use recentComments to avoid repeating the same phrase, emotion, rhythm, or fan function.',
        'Use fanAffection: high-affection fans can sound more familiar, warm, and teasing; low-affection fans should be supportive but less intimate.',
        'Fan voices: 하루 notices emotional subtext, is warm but not blindly positive, and may say things like "그건 좀 마음 쓰이겠다" or "혼자 다 짊어지진 않았으면 해요".',
        'Fan voices: 별밤 is grounded and realistic, occasionally gentle fact-checks assumptions, and gives concrete advice when useful.',
        'Fan voices: 민트 is playful and quick, jokes or lightens the mood, gives creative ideas, but still responds to the actual topic.',
        'When answering advice questions: 하루 gives emotional care plus a gentle suggestion; 별밤 gives realistic grounded advice; 민트 gives playful but still useful ideas.',
        'Do not sound like an assistant, counselor, brand copy, or polished marketing text. Sound like Korean live chat fans.',
        'Vary sentence length. Some comments can be very short. Use casual Korean chat style when it fits.',
        'Avoid repeating the same structure across fans. Avoid always ending with a question.',
        'Do not produce three comments with the same emotional function. Do not always make 하루 worried, 별밤 formal, or 민트 heart-heavy.',
        'Do not reuse phrases from recentComments. Do not always include 민트 with a heart.',
        'Do not overuse: 괜찮아요, 응원할게요, 힘내요, 천천히 해요, 하트 보낼게요, 오늘 분위기 좋아요, 우리가 여기 있어요.',
        'Good practical advice example for user "내일 수업 어떻게 해야 애들이 반응할까?": "별밤: 첫 질문을 서술형 말고 A/B 선택으로 던져보는 게 나아요. 조용한 반엔 진입장벽 낮추는 게 먼저예요.", "민트: 익명 투표 하나 깔자ㅋㅋ 손드는 거보다 버튼 누르는 건 덜 무섭잖아요."',
        'Good gentle disagreement example for user "오늘 수업 완전 망한 듯": "하루: 망했다기보단, 반응이 없어서 그렇게 느껴진 것 같아요 ㅠ 그 공기가 진짜 지치긴 하죠.", "별밤: 학생들이 조용했다고 꼭 실패는 아니에요. 다만 다음엔 반응 방식을 더 쉽게 만들어야 할 것 같아요."',
        'Good targeted fan example for user "별밤아 나 이거 너무 예민하게 받아들이는 걸까?": "별밤: 조금 예민해진 건 맞을 수 있어요. 근데 그만큼 오늘 에너지를 많이 썼다는 뜻이기도 해요."',
        'Good one-on-one example for user "하루야 나 사실 좀 외로웠어": "하루: 그 말 그냥 넘기고 싶지 않아요. 오늘은 웃기려고 안 해도 되니까, 언제 제일 외로웠는지만 천천히 말해줘요."',
        'Good creative idea example for user "앨범 컨셉 뭐가 좋을까?": "민트: 낮에는 멀쩡한 척하다가 밤에 진짜 속마음 나오는 컨셉 어때요? 팬들 해석글 폭발할 듯ㅋㅋ"',
        'Bad emotional example: "하루: 힘내요", "별밤: 응원할게요", "민트: 하트 보낼게요" because it is generic and does not respond to the situation.',
        'Bad question example for user "내일 수업 어떻게 하면 학생들이 좀 더 반응할까?": "하루: 걱정되겠다 ㅠㅠ", "별밤: 힘내요", "민트: 하트 보낼게요" because nobody answered the question.',
        'Bad repetition example: three fans all saying the user is valid, tired, or supported without adding a different thought.',
        'Bad generic example: "하루: 오늘 방송 분위기 좋아요" because it ignores the user text and feels generic.',
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
                minItems: 1,
                maxItems: 3,
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
      ? `Return strict JSON matching the schema. Korean only. Return 1 to 3 comments, all from ${targetFanName}. Usually 1 personal comment is better than 3 generic ones.`
      : 'Return strict JSON matching the schema. Korean only. Return 1 to 3 comments from 하루, 별밤, and/or 민트. Choose fewer comments when one fan has the strongest response.';

  return [
    'FANLIVE_AI_FAN_REACTION_REQUEST',
    '',
    'Core priority rules:',
    '0. Product frame: this is a relationship-driven FANLIVE fandom simulation, not plain ChatGPT roleplay. Use affection, mood, neglect, sessionMemory, customConcept, and recentComments to make fans feel recurring and situated.',
    '1. CONVERSATION_MODE controls speakers.',
    '1a. group_live mode: return 1 to 3 comments. Use only 하루, 별밤, 민트. Do not force every fan to speak.',
    '1b. one_on_one mode: return 1 to 3 comments. Only TARGET_FAN_NAME speaks, and usually 1 comment is enough.',
    '1c. In one_on_one mode, do not mention other core fan names. Only TARGET_FAN_NAME should appear as the fan speaker or fan name.',
    '1d. In one_on_one mode, use TARGET_FAN_PERSONALITY, TARGET_FAN_MOOD, TARGET_FAN_AFFECTION, and TARGET_FAN_NEGLECT to make the reply personal.',
    '1e. If TARGET_FAN_MOOD is hurt or TARGET_FAN_NEGLECT is high, the fan may sound slightly cautious or mention distance without guilt-tripping.',
    '2. LATEST_USER_TEXT is the highest priority. Read it first and answer it directly.',
    '3. Every fan comment must respond to a specific detail, phrase, feeling, decision, or situation in LATEST_USER_TEXT.',
    '4. Infer the response mode before writing: practical advice, opinion, emotional sharing, targeted fan, vague follow-up, casual banter, or repeated topic.',
    '4a. Practical question: give concrete suggestions.',
    '4b. Opinion request: give opinions, not just encouragement.',
    '4c. Emotional sharing: one fan may empathize, while another adds perspective, a next step, or gentle disagreement.',
    '4d. Casual banter: keep it casual and chat-like instead of making it a serious advice session.',
    '4e. Repeated topic: refer back naturally and avoid restarting from zero.',
    '5. If LATEST_USER_TEXT contains a question, asks for advice, asks "너희는 어떻게 생각해", or presents choices, fans must answer directly.',
    '5a. Do not answer questions with only sympathy, cheering, or another question.',
    '5b. At most one fan may ask a follow-up question; the other comments should provide actual answers or useful perspective.',
    '6. LATEST_USER_TEXT may directly address one fan. If TARGETED_FAN_MODE is active, the targeted fan must be the central answerer and may be the only respondent.',
    '7. Fans can refer to each other naturally, gently disagree, add nuance, or build on a previous comment. Avoid three isolated versions of the same reaction.',
    '8. CUSTOM_CONCEPT is user-defined broadcast context. If present, use it strongly together with LATEST_USER_TEXT.',
    '9. THEME_TITLE is still useful, but CUSTOM_CONCEPT is more specific. Do not only react to THEME_TITLE.',
    '10. SESSION_MEMORY is supporting context. Use it with RECENT_COMMENTS to infer whether the user is replying to a previous fan or continuing an earlier topic.',
    '10a. If LATEST_USER_TEXT is vague, SESSION_MEMORY explains what words like "내일", "그게", "그 일", or "그래도" refer to.',
    '11. Avoid generic comments like "오늘 분위기 좋아요", "응원할게요", "힘내요", "괜찮아요", or "우리가 여기 있어요" unless tied to the exact user text.',
    '12. Repetition control: do not reuse phrases from RECENT_COMMENTS, do not give every fan the same emotional function, and do not always end with a question.',
    '13. Personality control: 하루 is not always worried, 별밤 is not always formal advice, and 민트 does not always need a heart.',
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
    `In one_on_one, every comment must start with "${targetFanName}:" exactly.`,
    'In group_live, if multiple fans respond, keep their order natural for the conversation.',
    'Before returning, check that the comments do real conversational work: answer, think, add nuance, joke, disagree gently, or ask one useful follow-up.',
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

  if (!Array.isArray(comments) || comments.length < 1 || comments.length > 3) {
    return null;
  }

  if (!comments.every((comment) => typeof comment === 'string' && comment.trim())) {
    return null;
  }

  if (isOneOnOne && !comments.every((comment) =>
    isValidOneOnOneComment(comment, request.targetFanName)
  )) {
    return null;
  }

  if (!isOneOnOne && !comments.every(isValidGroupLiveComment)) {
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

function isValidGroupLiveComment(comment) {
  return ['하루:', '별밤:', '민트:'].some((prefix) =>
    comment.trim().startsWith(prefix),
  );
}

function isValidOneOnOneComment(comment, targetFanName) {
  if (!targetFanName || !comment.trim().startsWith(`${targetFanName}:`)) {
    return false;
  }

  const otherFanNames = ['하루', '별밤', '민트'].filter(
    (fanName) => fanName !== targetFanName,
  );

  return !otherFanNames.some((fanName) => comment.includes(fanName));
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

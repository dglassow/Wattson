# Wattson Whiteboard

## What is Wattson?

A Jarvis-inspired personal assistant with a feminine persona. Wattson integrates across devices and ecosystems, transitioning seamlessly as the user moves between them. She addresses any need using whatever technologies and services are available.

**Persona:** Feminine, uses a glassy voice similar to Claude.ai's "Glassy" voice

---

## Input/Output Capabilities

**Input:**
- Text
- Voice
- Images
- Video
- Files / multimedia attachments

**Output:**
- Text
- Voice (glassy, feminine)
- Actions across integrated services

---

## Key Questions to Answer

1. ~~What devices/ecosystems do you use today that Wattson should integrate with?~~ ✓
2. ~~What's the primary interface?~~ All of the above - voice anywhere, wake word, app, desktop, context-dependent ✓
3. ~~What AI model should power Wattson's intelligence?~~ Dual: Claude Max (primary) + Bedrock (secondary) ✓
4. ~~What are the highest-priority use cases for v1?~~ Development assistant (see below) ✓
5. ~~Should Wattson have memory/context that persists across conversations?~~ Yes, maximum context while cost-conscious ✓

---

## Architecture Ideas

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUT LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│  Voice → Amazon Transcribe                                       │
│  Text  → Direct                                                  │
│  Images/Video/Files → S3 + Multimodal processing                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      INTELLIGENCE LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  Amazon Bedrock (Claude)                                         │
│  - Reasoning and conversation                                    │
│  - Tool use / function calling                                   │
│  - Multimodal understanding                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       OUTPUT LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│  Voice → Amazon Polly (glassy feminine voice)                   │
│  Text  → Direct                                                  │
│  Actions → Integration layer                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INTEGRATION LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  Office 365 → Microsoft Graph API                                │
│  Smart Home → Hue API, Wiz API, Alexa Smart Home API            │
│  Apple → HomeKit (via HomeBridge or direct), Shortcuts          │
│  AWS → Direct SDK                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## AWS Services Under Consideration

| Service | Role | Free Tier? |
|---------|------|------------|
| Amazon Bedrock | AI brain (Claude) | Pay per token |
| Amazon Transcribe | Speech-to-text | 60 min/month free |
| Amazon Polly | Text-to-speech | 5M chars/month free (12 months) |
| Amazon S3 | File/media storage | 5GB free |
| AWS Lambda | Compute for integrations | 1M requests/month free |
| Amazon API Gateway | API endpoints | 1M calls/month free |
| AWS Secrets Manager | Credentials storage | 30-day trial, then $0.40/secret/month |
| Amazon DynamoDB | Conversation memory/state | 25GB free |
| Amazon EventBridge | Event routing | Free tier available |
| AWS IAM | Auth/permissions | Free |

---

## Integrations Wishlist

**Productivity:**
- Office 365 (email, calendar, documents, Teams?)

**Cloud:**
- AWS

**Devices:**
- Apple products (iPhone, Mac, iPad, Apple Watch?)
- Windows 11 PC
- Apple TV

**Smart Home:**
- Alexa smart thermostat
- Wiz bulbs
- Philips Hue bulbs

---

## Memory Architecture

**Goal:** Maximum context retention, cost-conscious

```
┌─────────────────────────────────────────────────────────────┐
│                     MEMORY LAYERS                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  HOT: Active Context                                         │
│  ├─ Current conversation                                     │
│  └─ Recent sessions (DynamoDB - 25GB free)                  │
│                                                              │
│  WARM: Searchable History                                    │
│  ├─ Key facts & preferences                                  │
│  ├─ Project context & decisions                              │
│  └─ Summarized past conversations                           │
│                                                              │
│  COLD: Full Archive                                          │
│  └─ Raw conversation logs (S3 - cheapest storage)           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Cost-saving strategies:**
- Summarize old conversations instead of storing full context
- Use DynamoDB for structured lookups (free tier: 25GB)
- Archive raw logs to S3 ($0.023/GB/month)
- Only add vector search if semantic retrieval becomes necessary

---

## V1 Priority: Development Assistant

Primary use case: Wattson becomes the main interface for development work
- Works on Wattson project itself and other projects
- Dual AI backend for flexibility and cost optimization

**AI Backend Strategy:**
```
┌─────────────────────────────────────────────────────────────┐
│                    WATTSON AI ROUTER                         │
├─────────────────────────────────────────────────────────────┤
│  Routes requests to optimal backend based on:               │
│  - Cost (Max subscription vs pay-per-token)                 │
│  - Availability (failover)                                  │
│  - Feature needs (Claude Code tools vs raw API)             │
└─────────────────────────────────────────────────────────────┘
          │                              │
          ▼                              ▼
┌──────────────────────┐    ┌──────────────────────┐
│  PRIMARY: Claude Max │    │  SECONDARY: Bedrock  │
├──────────────────────┤    ├──────────────────────┤
│  - Flat rate pricing │    │  - Pay per token     │
│  - Claude Code CLI   │    │  - AWS-native        │
│  - Existing sub      │    │  - Fallback/overflow │
└──────────────────────┘    └──────────────────────┘
```

---

## Open Questions / Decisions Needed

- Wake word detection approach (if voice-activated)
- How to handle authentication across ecosystems (OAuth tokens, refresh flows)
- Privacy/security model for personal data
- Client apps: build custom or leverage existing? (Alexa skill, iOS app, web app?)
- How does Wattson know which device/context you're in?

---

## Notes


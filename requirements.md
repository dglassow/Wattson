# Wattson Requirements and Purpose

## Purpose
Build a compliant, local-first personal assistant that aggregates and acts across multiple employer ecosystems without bypassing MFA/SSO. Access is performed by isolated per-org agents on the user's devices, while a centralized environment provides reasoning, memory, and orchestration.

## Requirements
- Isolation: one container per organization with separate credentials, storage, logs, MCP tools, and configs.
- Interactive auth: browser/device-code SSO + MFA per org; no bypass or exception requests.
- Local-first access: org APIs only from local agents under the user's authenticated session.
- Central aggregation: summaries/metadata only by default; full content only with explicit approval.
- Bidirectional execution: local agents execute tasks via approved APIs or proxy queues when direct access is blocked.
- Auditability: per-org action logs with clear attribution and approvals.
- Extensibility: MCP-first tool model to add org tools safely.

## Constraints and Safety Defaults
- Default to summary-only sync to the central service.
- Enforce per-org data boundaries; no cross-org data mixing without explicit user intent.
- Respect organizational security policies and app access rules.

## System Components and Responsibilities
- Local Agent (per org): authenticates via SSO/MFA, runs MCP tools, fetches data, and executes actions within that org.
- Central Brain: performs reasoning, planning, memory, and aggregation; never directly calls org APIs.
- MCP Gateway (optional cloud): brokers tool calls for non-local clients; enforces auth, quotas, and logging.
- Client Apps: CLI (primary) and iOS/watch; send queries and receive text + voice responses.

## Data Flow (High-Level)
- User query → Client → Central Brain → (optional MCP tool selection) → Local Agent executes → Central Brain summarizes → Client renders text + voice.
- Local Agent → Central Brain sync: summaries/metadata by default; full content only with explicit approval.
- Central Brain → Local Agent: task queue for approved actions; agent executes and reports results.

## Interfaces and Protocols
- MCP tool interface for all integrations; per-org tool registry enforced locally.
- Task queue interface for proxy execution (e.g., S3/SQS with signed payloads).
- Audit log schema shared across agents for consistent attribution.

## Security and Compliance Model
- Tokens scoped per org, stored locally per container and never shared cross-org.
- Least-privilege API scopes for each integration.
- Explicit user approvals for any action that modifies org data unless allowlisted.

## Logging and Auditability
- Per-org logs stored locally with optional summary sync.
- Central logs contain only aggregated metadata and action receipts.

## User Journeys (V1)
- CLI: user asks a dev task, agent summarizes relevant org data locally, central brain returns a response with text and optional voice.
- iOS/watch: user speaks a request, app transcribes, central brain reasons, local agent executes, app plays text + voice.
- Approval flow: for write actions, agent prompts for approval, then executes and reports results.

## Integration Policy Matrix (Draft)
- Office 365: read by default, write with approval; device-code auth + MFA.
- Jira: read by default, write with approval; OAuth via local agent.
- Slack: read by default, write with approval; OAuth via local agent.
- Teams: read by default, write with approval; Graph API via local agent.
- GitHub: read by default, write with approval; OAuth or PAT stored locally.
## Open Decisions
- Data sharing policy per org (full vs summary-only) and escalation flow.
- Approval model for automated actions (always approve vs allowlists).
- Proxy execution mechanism (S3/SQS/event-driven) and retry policy.

## Non-Goals (v1)
- Any method that bypasses MFA/SSO or violates organizational policies.
- Direct central access to org APIs without a local agent.

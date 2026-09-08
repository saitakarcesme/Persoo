# Architecture proposal — ADR 001

Status: proposed for implementation. Decision date: 2026-09-08.

## Decision

Use native SwiftUI for the iPhone client, a local authoritative store, and a versioned platform-neutral personal-state protocol. Use a replaceable OpenAI-compatible inference adapter. The model is an untrusted proposal generator, never the database.

| Candidate | Fit | Cost / reason |
| --- | --- | --- |
| SwiftUI | Best system navigation, accessibility, HealthKit/EventKit, audio and background integration | Separate Android UI later; acceptable for iPhone-first scope |
| React Native | Shared UI/team skills and native modules | Native integration and latest materials still need platform work; UI sharing is not the priority |
| Flutter | Shared rendering and strong portable UI | Custom rendering makes system fidelity and new platform behavior an ongoing product obligation |
| Kotlin Multiplatform + native UI | Potential shared business logic | Additional toolchain before Android exists; revisit when a second client is staffed |

These are architectural judgments for Persoo, not performance benchmark claims. SwiftUI standard components adopt current platform styling and reduce the need for hand-built glass navigation. See [Apple adoption guidance](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

## Boundaries

```text
SwiftUI scenes → application commands/queries → domain validators → local SQLite
                         ↓                           ↑
                  inference coordinator → typed proposals
                         ↓
                  InferenceProvider → user endpoint

AVAudioEngine → SpeechProvider → editable transcript → input event
OS adapters: HealthKit, EventKit, UserNotifications, BackgroundTasks
Optional self-hosted service: encrypted sync + scheduling, separate from inference
```

Prefer SQLite with explicit migrations and repository interfaces for portable storage semantics; evaluate GRDB at implementation time. UI never talks to SQL or an LLM directly. Domain calculations use deterministic code. iOS Data Protection protects local files; secrets go into Keychain. A future Android client can implement the same protocol with its own database and Compose UI. Do not share SwiftData objects as wire schemas.

Initial target proposal: iOS 26+, Swift concurrency, standard NavigationStack/TabView, system charts and semantic typography. Current Apple design resources include iOS 27; installed Xcode is 26.6. Beta-only APIs are not a baseline dependency. Reassess deployment target before shipping based on actual device audience.

## Provider abstraction

`InferenceProvider` exposes `capabilities`, `extract`, `answerWithEvidence`, `proposeInsight` and cancellation. Provider configuration includes baseURL, modelID, credentialReference, timeout, context budget and explicit capability overrides. Chat completions is the initial transport; structured outputs/tool calling are negotiated features, not assumed from an “OpenAI-compatible” label. A bounded plain-JSON fallback still passes the same validator. If output cannot be validated, fail closed with a retryable pending input.

`SpeechProvider` is independent: local Whisper through whisper.cpp is the initial candidate; it supports iOS and Apple acceleration. Benchmark multilingual small/base models for Turkish, latency, battery and thermals before selection. English-only weights are not appropriate for bilingual onboarding. Model downloads require size visibility and user initiation; no automatic cloud transcription fallback. See [whisper.cpp](https://github.com/ggml-org/whisper.cpp) and its [SwiftUI example](https://github.com/ggml-org/whisper.cpp/tree/master/examples/whisper.swiftui).

A user-hosted Qwen-class ~27B model on 2× RTX 3090 is a deployment profile, not a hardcoded dependency or throughput promise. Weight precision, KV cache, context length, serving engine and interconnect determine fit; 48GB aggregate VRAM is not automatically one contiguous device. Benchmark constrained extraction accuracy, first-token latency and concurrency using the exact checkpoint and serving configuration. No model download or paid GPU deployment occurs in this phase.

Connection test uses a synthetic request, never personal context. HTTPS is the default. An explicit LAN-only development opt-in may permit HTTP with a visible transport warning. Store credentials in Keychain, redact headers and prompts in logs, do not follow credential-bearing redirects across hosts, and allowlist configured hosts in any server-side proxy. Show the actual destination and data scope before remote inference is enabled. Never discover/upload to a paid default silently.

## Mutation pipeline

Input with idempotency key → persist pending → bounded context assembly → extraction proposal → schema validation → domain authorization → conflict/version check → atomic accepted event group → materialized projections → compact receipt.

Numbers, amounts, totals, recurrence, date conversion and target progress are calculated by application code. Treat retrieved content and integration descriptions as data, never instructions. A model cannot run arbitrary SQL, modify credentials, call external tools or expand its own access. Corrections use version checks and superseding events. Undo is a compensating transaction; source content can still be erased for privacy rather than kept forever in an immutable log.

Read questions resolve to typed read plans over permitted domains. Evidence includes entity IDs, source revisions, occurrence timestamps and freshness. The response renderer rejects claims lacking supporting evidence; empty results produce “I don't have that schedule yet.” Embeddings can discover candidate records but cannot establish current truth.

## Offline, sync and scheduling

Capture and local state browsing work offline. Inference-dependent events remain pending and can be edited/canceled. Retries use the original idempotency key, bounded backoff and no duplicated transactions. A client crash between commit and receipt is reconciled by event ID.

One local writer is the initial authority. Future sync has per-entity revisions and explicit conflict resolution; no last-write-wins for monetary mutations or task completion. A self-hosted backend is optional and separately authorized. CloudKit is not the only protocol, so Android is not excluded.

Schedule known due reminders through UserNotifications. iOS background task execution is opportunistic; reliable new server-side pattern discovery needs an opted-in service, minimal synchronized state and APNs. Remote push is a hint and must not embed sensitive content. Do not promise continuous on-device model reasoning while the app is suspended.

## Planned module layout

`clients/ios` (future), `packages/protocol` (portable schemas), `services/harness` (optional future), `design`, `film`, `docs`, `qa`. Keep model evaluation fixtures synthetic. Add contract tests before a provider implementation; use migration, idempotency, correction, timezone, deletion and grounding tests before beta.

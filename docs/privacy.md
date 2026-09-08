# Privacy design

Status: requirements, not an audit or implemented security guarantee.

Local storage and local transcription are the defaults. Remote inference is user-configured and shows endpoint identity and data scope. Self-hosting does not itself guarantee privacy: an endpoint operator may log requests. The app must explain that boundary without claiming end-to-end encryption when a server needs plaintext to infer.

| Data | Default handling | User control |
| --- | --- | --- |
| Raw microphone audio | Volatile capture, discarded after accepted transcript; cancellation discards | Optional retention requires explicit choice |
| Transcript | Local, editable; no analytics ingestion | Delete source and dependent facts |
| Structured state | Local protected store | Inspect, correct, export, erase |
| Explicit context | Local with provenance | Edit, invalidate, forget |
| Inferred context | Visibly labeled; sensitive inference off | Confirm, reject, forget and suppress relearning |
| Embeddings | Local derived index initially | Cascading invalidation and rebuild |
| Credentials | Keychain only | Replace or remove |
| Diagnostics | Redacted operational codes | Opt in to sharing selected reports |

Permissions are contextual: microphone at recording, HealthKit when connecting health data, calendar when importing schedules, notifications when enabling reminders. Denial preserves a useful manual path. Do not request contacts, location or photo library access for speculative future uses.

Every query has a minimum domain scope. Sending a hydration update must not include financial history. Prompt logs, crash reports, URLs and telemetry must not contain raw personal data. Third-party endpoint processing is disclosed separately from local recording. Health data is not used for advertising, profiling or financial persuasion. Savings opportunities use purchase records voluntarily entered; they must not exploit inferred medical or psychological vulnerabilities.

Deletion is a lifecycle: erase source payloads, context revisions, embeddings and derived insights; cancel pending jobs/reminders; enqueue synchronized deletion tombstones without sensitive payloads. Backups have a documented bounded expiry; do not claim immediate removal from third-party server logs. Store minimal suppression state only with a clear explanation so forgotten inferences do not regenerate. Event-log provenance must not become an excuse for permanent retention.

Threats to validate: device loss, endpoint impersonation, leaked credentials, malicious integration text, prompt injection, duplicate writes, stale sources, cross-user retrieval, unintended lock-screen disclosure and re-identification through logs. Release requires a data-flow inventory, dependency review, export/deletion tests and accurate store privacy disclosures. No legal compliance certification is claimed by these documents.

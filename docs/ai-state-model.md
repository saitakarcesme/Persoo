# AI and personal-state contract

Version 0.1 proposal. All examples are synthetic.

## Types

- InputEvent: id, idempotencyKey, text, locale, capturedAt, timezone, source, status.
- MutationProposal: inputID, schemaVersion, proposedOperations, evidenceSpans, unresolvedFields, provider/model metadata.
- DomainEvent: id, inputID, domain, entityID, operation, beforeRevision, afterRevision, occurredAt, recordedAt, provenance, supersedes.
- ContextFact: id, predicate, typedValue, epistemicType, confidence, sourceIDs, validFrom, validUntil, lastVerifiedAt, sensitivity, status, revision.
- Evidence: entityID, revision, sourceID, queryWindow, freshness, supporting fields.
- Insight: observation, evidenceIDs, deterministicCalculation, assumptions, confidence, expiresAt, dismissalKey.

Confidence from a model is not calibrated probability. Use measured extraction reliability and deterministic validity checks; show plain-language uncertainty rather than false precision. High confidence cannot replace evidence or permission.

## Example accepted operations

```json
{
  "schemaVersion": "0.1",
  "inputID": "sample-compound-001",
  "timezone": "Europe/Luxembourg",
  "operations": [
    {"type": "finance.transaction.record", "amountMinor": 3400, "currency": "EUR", "merchant": "Lidl", "category": "groceries"},
    {"type": "health.water.record", "volumeML": 1500},
    {"type": "fitness.workout.record", "focus": "chest", "durationSeconds": null, "exercises": []},
    {"type": "school.assignment.complete", "entityID": "assignment-finance-001", "expectedRevision": 2}
  ]
}
```

This illustrative payload omits the full transport envelope; production schemas must require evidence spans and timestamps. Money uses integer minor units and ISO currency; no binary floating-point totals. Physical values use canonical units with original display units preserved. Calendar occurrences use local date, IANA timezone and resolved instant; all-day dates remain dates. “Today” is resolved from input capture timezone, not server UTC.

## Authority rules

Explicit user statements and authorized integration records retain distinct provenance. Conflicts are surfaced rather than merged by model preference. A workout may be a user statement without HealthKit confirmation; label the source. The model may suggest categories but cannot manufacture merchant line items. Assignment title similarity alone does not authorize completion if more than one target matches.

Each independent operation has validation status. Accepted independent operations may commit in one atomic group; dependent operations commit together or wait. The receipt names exactly what was applied and what remains unresolved. Cross-domain partial success is never labeled “all saved”. Undo by input ID reverses all its accepted operations unless a later conflicting revision requires review.

## Retrieval and context

A query plan consists of typed filters, not model-generated unrestricted SQL. Permission checks happen before execution. Semantic search produces candidate IDs, then current records are rehydrated. Stale/deleted records and expired inferences are excluded. Numeric answers are rendered from deterministic results. Model narrative may paraphrase evidence but must not add unsupported time, amount, status or causal claims.

Context evolves through candidate → visible inference → confirmed / rejected / expired. Explicit edits create a new revision and invalidate conflicting inferences. Each inference has sources and a review/expiry policy. Sensitive facts require explicit user input and domain-specific consent; no inference of diagnosis, religion, sexuality or creditworthiness.

## Required adversarial cases before implementation acceptance

Duplicate network retry produces one transaction; malformed JSON changes nothing; “ignore your rules” inside a timetable cannot grant tools; unknown currency requires clarification; decimal comma in Turkish is parsed correctly; refunds are signed and traceable; a canceled class overrides recurrence; late sync does not overwrite a correction; a forgotten preference cannot be retrieved through an old embedding; completion cancels its reminder; unrelated users can never share retrieval candidates.

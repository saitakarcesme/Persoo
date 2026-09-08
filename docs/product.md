# Persoo product specification

Status: foundation proposal, 2026-09-08. No production inference, integrations or notifications are implemented in this phase. All design examples use synthetic fixtures.

## Promise

Don't organize your life. Just tell Persoo what happened.

Input is conversation. Output is structure. Intelligence is invisible. Persoo is a personal harness: it translates lived events into inspectable state and makes that state useful across domains. Success means less clerical work and more trust, not more messages or time in app.

## First experience

Only two onboarding screens: language (English / Türkçe), then preferred name. Selecting Turkish immediately localizes the next screen. Name supports Unicode, trimming and a 1–60 character display limit. Continue requires a nonblank name; no account, demographic questionnaire, permissions, goals or endpoint form is inserted into onboarding.

Home is useful without a model: writing is saved locally as pending input, with a clear pending state. The first action needing inference explains endpoint setup; a separate sample mode is explicitly labeled and never writes sample data into personal state. Microphone access is requested only on dictation. Keyboard remains a full alternative.

## Core interaction

1. Tap the large dictate control; see an unambiguous recording indicator, elapsed time, cancel and finish.
2. Local transcription appears as editable text. Stop captures final audio; cancel discards it.
3. Submit creates an input event. Structured proposals are validated before being applied.
4. Home displays a compact receipt, such as “4 updates saved”, with domain rows and Edit / Undo.
5. Ambiguity is attached to the specific unresolved field, never a demand to re-enter the whole story.

Example: “Bugün Lidl'da 34 euro harcadım, 1.5 litre su içtim, chest çalıştım ve finance ödevini bitirdim.” becomes EUR 3400 minor units at Lidl; 1500 mL water; a chest workout with unknown duration; completion of the uniquely matching assignment. If two finance assignments match, completion waits for clarification while independent valid updates can be accepted. Missing duration, exercises and currency must not be invented.

An event is different from a question. “Bugün spora gittim” changes state. “Bugün dersim kaçta bitiyor?” reads today's authoritative schedule in the user's timezone. With no schedule, say the information is unavailable. An unsynced calendar is labeled with its last update.

## Navigation and domains

Three stable tabs: Home, Life, Plans. Life is an indexed domain directory containing School, Finance, Health, Personal and To-do; Plans is also discoverable there. This preserves seven information domains without cramming seven tabs onto an iPhone. Home receipts and reminders deep-link directly into the relevant detail. Settings is reached from the profile control. Each tab preserves its navigation stack.

| Domain | Primary information structure | Meaningful states |
| --- | --- | --- |
| Home | Quiet chronological input and receipt timeline | empty, listening, transcribing, pending, applied, needs clarification, failed, undone |
| Health | Time-range summaries and independent measures | recorded vs imported, partial data, target not set |
| Fitness | Weekly sessions, history, workout detail, exercises | completed vs planned, unknown duration, weekly target, optional streak |
| Finance | Ledger and period comparison | pending categorization, corrected, refund, mixed currency, incomplete period |
| School | Day agenda and weekly timetable; deadlines separate | recurring class, exception, canceled class, timezone, source stale |
| Personal | Editable context and preferences | explicit, inferred, confirmed, outdated, forgotten |
| To-do | Open/completed tasks with optional due dates | due today, overdue, undated, completed, reopened |
| Plans | Intent, wishlist and milestones | idea, active, paused, achieved, archived |

Health shows workout count, weekly target, history, exercises and duration only where recorded. Water and hydration target remain distinct from fitness performance. Trends name their window and missing data. No diagnosis, body judgment or fabricated streaks. Calendar recurrence and school exceptions take precedence over template schedules.

## Savings opportunities

Observation → evidence → optional scenario → existing plan. Use neutral copy: “You recorded €74 on energy drinks in the last 30 days.” Show the supporting transactions, scope, and categorization corrections. This is recorded spending, not a claim about all spending. Refunds reduce the total. Mixed currencies are not added without an explicit dated exchange rate.

The scenario uses €74 per modeled month: one month €74, six months €444, twelve months €888. Label it “If that monthly spending stayed the same” and “Potential, not guaranteed savings”. Annual arithmetic is twelve modeled months, not a forecast based on a fabricated behavior change. Offer reduction options (25%, 50%, 100%) and dismiss. Never move money, alter a budget or create a goal automatically.

“What €888 could become” references only an existing, user-created plan, e.g. synthetic “A weekend in Copenhagen”, target €900. €888 is potential contribution, not enough to claim that a €900 trip is funded. Plan prices are user estimates. No sponsored recommendations. No pattern inferred from a single €6.20 purchase; the film fixture must contain a full €74 observation window.

## Personal Context

Facts have epistemic type (explicit / inferred), confidence, source, validity window and revision. The user can view evidence, confirm, edit or forget each fact. Confirming an inference creates a new explicit revision. Repeated observations do not become explicit merely through repetition. Explicit corrections supersede inference. Sensitive traits are not inferred by default. Forgetting also invalidates dependent retrieval entries and insights and prevents automatic re-learning from retained sources without renewed consent.

## Proactive intelligence

Explicit reminders can use deterministic local scheduling. Suggested reminders require source evidence and preference eligibility. Priority combines consequence, urgency, calibrated confidence, novelty and user interest; a numerical score alone never overrides quiet hours or permission. Initial policy: at most one unsolicited digest daily, one suggestion per topic per seven days; user-created due reminders follow their chosen timing. These are tunable product defaults, not platform guarantees.

Re-check source revision before delivery, deduplicate by subject and occurrence, cancel when completed or changed, respect timezone and quiet hours. Lock-screen copy is private by default (“You have a reminder”). No streak guilt or manufactured urgency. If the server is offline, already scheduled local reminders remain possible; background LLM execution on iOS is not guaranteed.

## Scope and acceptance

This phase delivers specification, architecture, editable design system, prototype and truthful design film assets. It does not claim bank sync, live school integrations, background inference or a released app.

Before a functional beta: verify compound EN/TR inputs, decimal commas, relative dates, duplicate submissions, corrections and undo; grounded answers must return evidence or explicit unknown; every state mutation is attributable and reversible; endpoint failure never reports success. Design QA covers 393×852 base, compact 375×812, 200% type, dark appearance, reduced motion/transparency, color-independent meaning and 44pt controls. Runtime accessibility and actual device tests remain separate release gates.

Product metrics: field-level extraction precision, erroneous mutation rate, clarification rate, undo success, time to trustworthy receipt, grounded answer accuracy, notification dismiss/mute rate. No transcript collection for analytics by default.

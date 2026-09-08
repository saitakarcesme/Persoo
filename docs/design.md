# Persoo design direction

Status: specification and partial Figma foundation. Three pages and 46 variables exist; the Starter MCP quota blocked typography/component/screen creation. Visual QA has not run. Research checked 2026-09-08. Use the official [HIG](https://developer.apple.com/design/human-interface-guidelines/) and [Apple Design Resources](https://developer.apple.com/design/resources/), which currently link the iOS 27 kit. Do not confuse a kit's availability with the installed SDK or minimum OS.

## Identity: a quiet record of a living day

Warm near-white canvas, ink typography and a restrained deep teal interaction accent. The distinctive gesture is an open timeline: spoken language resolves into small aligned domain receipts. Space, baseline alignment and meaningful typographic contrast create hierarchy. Content lives on the page; contained surfaces are reserved for actionable insights or grouped controls. No assistant avatar, sparkle identity, neon, AI gradient, omnipresent cards or chat-bubble wallpaper.

Provisional wordmark: Persoo in a restrained semibold sans. The primary UI is SF Pro using semantic iOS text styles. Film typography outside UI will use an appropriately licensed font; do not redistribute Apple font files in the open-source repository. Symbols retain their semantic SF Symbols names and are used within Apple app UI, never as the Persoo logo. Consult resource licenses before distributing source glyphs or Apple assets.

## Foundations

| Role | Default points / leading | Weight | Native mapping |
| --- | --- | --- | --- |
| Large title | 34 / 41 | Bold | largeTitle |
| Title | 28 / 34 | Bold | title |
| Section | 22 / 28 | Semibold | title2 |
| Headline | 17 / 22 | Semibold | headline |
| Body | 17 / 22 | Regular | body |
| Secondary | 15 / 20 | Regular | subheadline |
| Caption | 13 / 18 | Medium | footnote |
| Metric | 48 / 52 | Semibold | scaled custom metric, monospaced digits |

Scale with Dynamic Type, preserve hierarchy, allow vertical reflow and avoid light weights for small text. These are Persoo design values, not a claim that every value is mandated by Apple. [Typography guidance](https://developer.apple.com/design/human-interface-guidelines/typography).

Spacing: 4, 8, 12, 16, 24, 32, 48, 64. Base horizontal content inset 24pt; compact layouts may use 20pt. Screen baseline 393×852pt, with responsive safe-area containers rather than fixed production coordinates. Minimum interactive hit area 44×44pt. Use 12pt radius for small controls, 20pt for exceptional grouped surfaces and capsules for floating controls; lists have separators and natural margins rather than a rounded wrapper for every row.

Semantic color roles are defined in `design/tokens.json`, with light/dark equivalents. They map to system colors where possible. Teal is an action affordance, not a domain coding scheme. Health, Finance and School differ by structure and data encoding. Do not depend on color alone for status.

Glass belongs to a floating navigation/control layer. Content surfaces remain opaque. Adopt system materials in SwiftUI instead of simulating refraction with stacked blur. Reduce Transparency uses an opaque surface; Increase Contrast strengthens foreground/separator contrast; Reduce Motion substitutes brief dissolves for position/scale changes. [Materials guidance](https://developer.apple.com/design/human-interface-guidelines/materials), [Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

Motion: acknowledgement 160ms, state transition 240ms, navigation around 320ms where custom motion is necessary. Native system transitions take precedence. Use ease-out for entry, ease-in for exit, interruptible actions, no waiting for decorative sequences. Recording waveform reflects actual audio amplitude, not invented activity. Reduced-motion UI stays semantically complete. [Motion guidance](https://developer.apple.com/design/human-interface-guidelines/motion).

## Component contract

| Component | Variants / properties | Usage |
| --- | --- | --- |
| ActionButton | Primary / Quiet / Destructive × Enabled / Pressed / Disabled; text label | 52pt primary action, 44pt minimum secondary hit area |
| TextField | Empty / Filled / Focused / Error; label, value, helper | Language/name and endpoint setup; secure key field separate |
| DictateControl | Idle / Listening / Transcribing / Unavailable; label | Large reachable input; cancel and keyboard alternatives |
| DomainReceipt | Applied / Pending / NeedsReview / Undone; symbol, title, value | Auditable state changes with source and revision details |
| Navigation | Home / Life / Plans selection | Stable labels, preserved stacks; no hidden changing tabs |
| LedgerRow | Expense / Refund / Unclassified; merchant, amount, category, date | Monospaced right-aligned amounts |
| AgendaRow | Class / Assignment / Exam / Canceled; time, title, place, source | Separate timeline axis; no finance-card reuse |
| ContextFact | Explicit / Inferred / Outdated; fact, provenance | User correction and forgetting always accessible |
| Observation | Available / Dismissed; evidence, scenario, plan reference | Optional suggestion; no coercive primary CTA |
| ReminderRow | Upcoming / Snoozed / Completed; subject, due, source | Deep link and dismiss/snooze actions |

Planned implementation: use auto-layout, semantic variable bindings, text properties, icon swap properties and actual component instances. Limit variant combinations; separate icon choice from state. Starter-plan mode constraints may require separate light/dark semantic collections rather than a paid upgrade. This preserves both themes without cost.

## Required screen inventory

| ID | Screen | Hierarchy and interaction |
| --- | --- | --- |
| 01 | Language | Open title, English / Türkçe choices, continue to localized name |
| 02 | Name | Single name field, system keyboard, bottom Continue |
| 03 | Home empty | Greeting, one inviting sentence, large dictate, keyboard alternative |
| 04 | Home populated | Natural input text, compact four-domain receipt, contextual next class |
| 05 | Dictation active | Live transcript, elapsed recording, finish/cancel, waveform |
| 06 | Health overview | Independent workout and hydration summaries with temporal context |
| 07 | Fitness detail | 3 of 4 weekly sessions, weekday chart, workout history, recorded duration/exercises |
| 08 | Finance overview | Period total, category distribution, latest ledger, single observation entry |
| 09 | Transactions | Day-grouped timeline; search/filter; refund and source access |
| 10 | Savings opportunity | €74 evidence, 1/6/12 month scenario, €900 existing plan, adjust/dismiss |
| 11 | School overview | Next class, assignments by deadline, weekly schedule entry |
| 12 | Today's schedule | Time axis, class locations, authoritative end time, source freshness |
| 13 | Plans | User-authored intentions, estimate and progress, paused/active distinction |
| 14 | Personal Context | Explicit and inferred sections, provenance disclosure, edit/forget |
| 15 | Proactive reminder | Source-backed due reminder, snooze/done, privacy-conscious delivery explanation |
| 16 | Model settings | Endpoint/model/secure credential, connection test, data destination and offline state |
| 17 | Life directory | Clear domain index connecting every screen without seven tabs |
| 18 | To-do | Open and completed tasks; deadline/undated separation |

Prototype flows: 01→02→03→05→04; Home receipt→domain; Life→every domain; Finance→transactions→opportunity→existing plan; School→schedule; Personal→context; reminder→assignment; profile→settings. Back returns to the correct parent, not a slideshow next screen. Language and appearance changes need documented variants. Keyboard and recording cancellation return without committing state.

## Visual QA gates

Inspect each screen at 1× phone size and a high-resolution export. Check text clipping, safe areas, contrast, touch dimensions, chart labels and sample-data consistency. Inspect compact width and 200% type reflow on representative complex screens. Explicitly assert SF Pro font family, bound variables and instance main-components. Test all prototype links. Screenshots cannot prove VoiceOver, thermal behavior, native glass or live speech; those require a running client and actual device validation before release. [Accessibility guidance](https://developer.apple.com/design/human-interface-guidelines/accessibility).

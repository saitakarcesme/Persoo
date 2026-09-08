# Local delivery update

The user authorized local design tools in place of completing Figma. Both concept films now use the shared SwiftUI design exports. See [storyboard](../film/storyboard.md), [production instructions](../film/README.md), [finished exports](../README.md#watch), and [QA](../qa/local-production.md).

The 54-second launch export is 1080p/60fps. The 24-second portrait concept is 886×1920/30fps, H.264 High Level 4.0, approximately 11Mbps, stereo AAC. These are synthetic design demonstrations. The portrait film needs actual app capture before App Store submission. The research below informed the production; earlier future-tense plans are superseded by the linked delivery report.

---

# Persoo film production brief

Status: research and pre-production constraints only. Final storyboard and production follow approved visual QA of the real Figma design. No film has been rendered yet.

## Truthfulness and deliverables

A. Launch film: 54-second target, 1920×1080 60fps master, restrained campaign treatment using actual Persoo design assets. Until a functional app exists, label it as a product concept / design prototype. Do not imply real inference, bank integration or scheduled notifications are already implemented.

B. App Store preview: 24-second target, 886×1920 portrait, 30fps H.264, progressive High Profile at most Level 4.0, target 10–12Mbps, stereo AAC 256kbps at 48kHz, under 500MB. Current Apple requirements allow 15–30 seconds and at most 30fps; 60fps launch master is a separate deliverable. Default poster position is 5s; deliberately select a readable actual-UI frame. [Technical requirements](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/).

Apple specifies footage captured on device and only in-app content. Figma animation alone can be a preview-format concept cut, but cannot honestly be called a submission-ready App Store preview. A functional capture build and device footage are a release dependency; no prototype is silently substituted. Prices shown in UI are synthetic transaction data, not app pricing; avoid promotional price claims. [App Preview guidance](https://developer.apple.com/app-store/app-previews/).

## Creative premise

“A small moment. A clearer picture.” Quietly show the connection between an everyday utterance and a personally meaningful plan. Restraint comes from readable holds, spatial continuity and exact transitions between actual data representations. Let the user decide what happens next. No exploding interfaces, fake spatial OS, stock lifestyle montage or orbiting device render.

Tagline candidates: “Your life, understood.” (original, ambitious); “Life, in context.” (more precise); “Tell it. See it clearly.” (interaction-led). Provisional recommendation: “Life, in context.” The final line should be judged against the actual cut.

## Planned story beats, to lock after design QA

Opening: user-recorded €6.20 transaction → structured receipt. Transition through an explicitly labeled 30-day window of synthetic supporting transactions totaling €74. Observation becomes a transparent optional €888 annual scenario. Link to the already existing €900 Copenhagen weekend plan without claiming it is funded. Broaden to fitness, schedule and an assignment reminder. End on Persoo and a single short line.

The film must not imply that a single purchase proves a pattern. The €6.20 entry is one of twelve records in `design/fixtures.json`; remaining entries predate it. No real user's financial, health or educational records enter the film.

## Pipeline evaluation

Remotion is suitable for deterministic typography, reusable UI assets, frame-accurate timings and reproducible exports. Its current [license](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md) allows individuals, qualifying small companies (up to three employees), nonprofits and noncommercial evaluation; other use needs a company license. It is not a permissively licensed dependency merely because the source is public. Eligibility must match the producing entity before commercial distribution. No paid license purchase is authorized.

Alternative: locally rendered Core Graphics/Core Animation UI plates plus FFmpeg editing. This gives native text rendering and avoids a React UI remake; editorial source must still preserve timing and shot controls. Choose the final production pipeline after actual Figma exports and font availability are verified. Neither pipeline makes a mockup genuine device footage.

## Sound and assets

Use an original synthesized score/sound bed with reproducible source, no sampled commercial music, Apple system sounds or downloaded unlicensed effects. Sparse tonal motif, subtle record/resolve accents, no voiceover needed. All meaning must remain legible muted. Maintain a rights ledger for fonts, UI exports, symbols, score and any third-party assets. Do not redistribute Apple font binaries.

Before production, lock eight artifacts: creative direction, storyboard, shot list, exact timing, transition specification, typography rules, sound plan and asset inventory. After production, inspect keyframes, every cut boundary, real-time playback and mobile readability. Measure duration, resolution, frame count, fps, codec/profile, audio channels/rate, peak level, file size and black/frozen frames. Do not claim studio-quality acceptance from file existence or ffprobe alone.

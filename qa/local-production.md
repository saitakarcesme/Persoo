# Local production review — 2026-09-08

## Delivered

- 19 native SwiftUI design screens; 30 PNG exports including four compact, four dark and three Turkish onboarding variants.
- 54-second campaign export: 1920×1080, 60fps, 3240 frames, H.264 High, stereo AAC 48kHz; approximately 5MB.
- 24-second portrait concept: 886×1920, 30fps, 720 frames, H.264 High Level 4.0, measured video bitrate 10.91Mbps, stereo AAC 48kHz (256kbps encoder target); approximately 33.5MB.
- Original synthesized score; no external music or samples.

## Checks performed

Native release build passed. All 30 images rendered. Contact sheets and selected full-resolution screens were inspected, including compact Home and Savings, Health and Settings. Initial headline truncation in Health and Settings was corrected and re-rendered. Final [screen overview](local-ui-overview.jpg) covers all exports.

Remotion TypeScript check passed. Both full videos rendered successfully. All ten campaign scenes were inspected using extracted frames; the portrait Savings frame was inspected at delivery resolution. The [film overview](film-overview.jpg) records the shot review. Browser playback reached the final 54.059-second endpoint. Three transition boundaries were inspected using nine extracted frames in film-transitions.jpg. FFmpeg decoded all 3240 campaign frames with no reported errors and detected no unintended black intervals. Intentional still holds are part of the pacing.

The [encoding report](encoding-report.txt) records the actual streams. The score measured approximately -19.4 LUFS integrated, 3.4 LU loudness range and -8.8 dBFS true peak, with no clipping. These are signal measurements, not a listening-panel assessment.

## Limits

This is a SwiftUI/macOS-rendered iPhone design prototype, not a running iOS application. Navigation is illustrative; model endpoints, recording, state changes and reminders are not live. Synthetic fixtures illustrate intended behavior. Static screenshot plates do not demonstrate real app transitions.

No physical iPhone, VoiceOver, Dynamic Type 200%, full localization, or integration tests have been performed. The portrait concept is technically formatted for the researched preview profile, but cannot be represented as compliant App Store content until captured from implemented app behavior. H.264 campaign output is the delivered 60fps master export; no ProRes master was generated.

# Persoo local film production

Original SwiftUI UI plates + frame-based Remotion editorial + original synthesized stereo score. See [storyboard](storyboard.md) for creative direction, shot list, timings, transitions, typography, sound and rights.

## Reproduce

1. From repository root, render the native design:

```sh
swift run --package-path design/native -c release PersooDesign --render design/exports
```

2. Copy UI assets and install pinned tooling:

```sh
cp design/exports/*.png film/motion/public/ui/
cd film/motion
npm ci
npm run dev
```

3. Generate the sound source using Python with NumPy, then normalize:

```sh
python3 film/synthesize_score.py
ffmpeg -y -i film/motion/public/launch-score-raw.wav -af loudnorm=I=-20:TP=-2:LRA=7 -ar 48000 film/motion/public/launch-score.wav
ffmpeg -y -i film/motion/public/preview-score-raw.wav -af loudnorm=I=-22:TP=-2:LRA=7 -ar 48000 film/motion/public/preview-score.wav
```

Run the sound commands from the repository root. Normalized WAV assets are included, so regeneration is optional.

4. From `film/motion`, render:

```sh
npx remotion render src/index.ts PersooLaunch ../out/Persoo-Launch-Film-60fps.mp4 --codec=h264 --crf=16 --concurrency=4
npx remotion render src/index.ts PersooPreviewConcept ../out/Persoo-Preview-Concept-source.mp4 --codec=h264 --crf=16 --concurrency=2
```

To create an editorial ProRes master, use `--codec=prores --prores-profile=hq` and a `.mov` output directly from the composition. Do not call a transcoded compressed export an uncompressed source master.

The preview delivery profile is finalized with FFmpeg at 886×1920, 30fps, H.264 High Level 4.0, 10–12Mbps target and stereo AAC 256kbps/48kHz. It remains a **design prototype**, not genuine on-device footage or a submission-ready App Store preview.

## Editing

`motion/src/Composition.tsx` contains named sequences and editorial layout. `Root.tsx` holds durations, frame rates and sizes. UI styling belongs in the SwiftUI source and must be re-exported; do not patch pixels or remake screens independently in marketing markup. All animation uses frame-derived values. Original score events are in `synthesize_score.py`.

## Rights

Original design/code/sound are MIT. Remotion has its own license and is not relicensed here. Recheck company eligibility before commercial distribution. System fonts and SF Symbols retain their licenses; font binaries are not included. No purchased services or third-party music were used.

# Persoo

**Don't organize your life. Just tell Persoo what happened.**

An open-source, iPhone-first personal intelligence harness. Conversation becomes structured, inspectable personal state across School, Finance, Health, Personal, To-do and Plans.

## Project status

Foundation phase. Product and architecture specifications are available. The [Figma product system](https://www.figma.com/design/oZ7fizliNxlUAKFrqxsqLw) has three pages and 46 color/measure variables; further work is blocked by the Starter MCP tool quota. Screens, components, prototype links and visual QA are not yet complete. No production application, inference backend, integrations, rendered launch film or submission-ready App Store preview exists yet.

The intended client is native SwiftUI. Inference uses a user-configured OpenAI-compatible endpoint, with local Whisper-based transcription proposed. The model proposes changes; validated structured state remains authoritative. Future clients share a versioned protocol rather than an Apple-only backend.

## Read the foundation

- [Product specification](docs/product.md)
- [Architecture proposal and alternatives](docs/architecture.md)
- [Design direction and screen inventory](docs/design.md)
- [Privacy requirements](docs/privacy.md)
- [AI and state model](docs/ai-state-model.md)
- [Film research and production constraints](docs/video.md)
- [Delivery status and QA](qa/status.md)

All examples are synthetic. No paid services, model downloads or app deployment are required to read or contribute to this phase. This repository currently contains design and architecture work, not an installable app.

## Contributing

Keep changes scoped and explain the user outcome. Preserve EN/TR input requirements, auditable state, explicit vs inferred context, offline capture and portable provider boundaries. Never commit credentials, personal transcripts, health records or private endpoint URLs. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Original project source and documentation: MIT. Third-party fonts, Apple resources, SF Symbols and video tooling retain their own licenses and are not relicensed by this repository. Persoo is independent and is not affiliated with Apple or OpenAI.

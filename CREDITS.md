# Credits

This project builds on and would not exist without the following work.

## KI-OS — Garrit Willson / KI-Pionier

The command-driven session workflow (`/checkin` → work → `/checkout`), the `/setup` onboarding pattern, and the use of CLAUDE.md as a central working instruction are inspired by KI-OS.

brainoutsourcing extends these ideas into a persistent knowledge system with wiki, planning, and context layers that compound across sessions.

- **Source:** Freely available via [YouTube](https://www.youtube.com/@KI-Pionier) and [Skool Community](https://www.skool.com/ki-pionier)
- **License:** No explicit open-source license. Freely shared with the community.

## Andrej Karpathy — LLM Wiki Pattern

Introduced the concept of separating immutable raw sources from LLM-maintained structured knowledge — the idea that an LLM "compiles" sources into wiki pages rather than just retrieving them.

brainoutsourcing implements this through the `raw/` + `wiki/` architecture, the compilation workflow (`/add-wiki`), and the wiki maintenance system (`/wiki-health`, lint, cross-references, progressive disclosure).

- **Source:** [GitHub Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- **License:** No explicit license (Gist)

## NightShift — GodModeAI2025

Inspired the autonomous overnight execution concept. brainoutsourcing implements this through a runbook generator (`/nightshift`), a task pipeline (`nightshift-pipeline.sh`), a heartbeat watchdog (`nightshift-watchdog.sh`), and an autonomy zone system (green/yellow/red) that governs what Claude may do without human oversight.

- **Source:** [GitHub Pages](https://godmodeai2025.github.io/NightShift/)
- **License:** Apache-2.0

## Tiago Forte — Building a Second Brain

The broader idea of a personal knowledge system with Capture → Organize → Distill → Express. brainoutsourcing is not an implementation of BASB but shares the underlying philosophy that externalized knowledge compounds over time.

- **Source:** [buildingasecondbrain.com](https://www.buildingasecondbrain.com/)
- **Note:** "Building a Second Brain" and "Second Brain" are registered trademarks of Forte Labs.

---

brainoutsourcing itself is [MIT licensed](LICENSE).

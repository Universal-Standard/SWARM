> ⚠️ **DEPRECATED — not the canonical SWARM repository.**
>
> As of 2026-08-12, repository reconciliation ([atlantis-ai-enhanced#1](https://github.com/UniversalStandards/atlantis-ai-enhanced/issues/1)) designated **[Universal-Standard/PROJECT-SWARM](https://github.com/Universal-Standard/PROJECT-SWARM)** as the canonical SWARM codebase (near-identical README/feature set to this repo, but with active recent engineering — this repo's last substantive commits were April 2026, issue-template/workflow edits only).
>
> **Why:** this repo implements the 16-branch-per-platform strategy (github/cloudflare/azure/aws × main/staging/development/features) that Notion's SWARM Project Hub already marked **"[ARCHIVED] 16-Branch Multi-Platform Deployment — Superseded by Cloudflare Workers."** It also has a SQLite database file (`swarm.db`) committed to the repo, which shouldn't be tracked in git. Kept here for historical reference only — do not build new features on this repo. Its 35 open issues should be triaged for anything not already covered in PROJECT-SWARM before this repo is fully retired.

---

# SWARM (PROJECT-SWARM)

**Multi-Platform AI Workflow Orchestration** - Build, execute, and monitor multi-agent AI workflows with visual drag-and-drop interface across GitHub, Cloudflare, Azure, and AWS.

*(Original multi-branch deployment content preserved below for historical reference — this branching strategy is superseded; use PROJECT-SWARM's Cloudflare/GitHub Pages/self-hosted deployment docs instead.)*

## ✨ Features

PROJECT-SWARM provides a complete AI workflow orchestration platform with 40+ features — visual workflow builder, multi-AI provider support, workflow orchestration, real-time monitoring, cost tracking, scheduled executions, webhook triggers, versioning, import/export, testing/debugging, analytics dashboard.

## 🏗️ Architecture

Frontend: React + Vite + ReactFlow + TailwindCSS. Backend: Node.js + Express + TypeScript. Database: PostgreSQL via Drizzle ORM (Neon, Supabase, or self-hosted). AI SDKs: OpenAI, Anthropic, Google GenAI.

## 📄 License

MIT License - see [LICENSE](./LICENSE) for details.

---

**Historical document — superseded 2026-08-12. See [Universal-Standard/PROJECT-SWARM](https://github.com/Universal-Standard/PROJECT-SWARM) for the active codebase.**

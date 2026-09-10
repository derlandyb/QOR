# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is the **QOR** root workspace — a spec/design planning repo, not application source code. QOR is a music-event discovery platform for the Greater Vitória region (Vitória, Vila Velha, Serra, Cariacica), connecting fans with venues/promoters across mobile, web, and admin surfaces.

Per `.specs/project/ARCHITECTURE.md` §1, the repository topology is this root repo plus 5 submodules — `qor-api` (Laravel), `qor-mobile` (KMP + Compose/SwiftUI), `qor-admin` (Next.js), `qor-website` (Next.js), `qor-landingpage` (Next.js) — all checked out, though only `qor-api` has feature work started so far (see `.specs/project/STATE.md`). There is no build/lint/test tooling in this repo itself; those commands belong to each submodule (see §8 of ARCHITECTURE.md for the Docker/Makefile/CI conventions each submodule must follow).

## Workflow: spec-driven planning via `tlc-spec-driven`

This repo is being developed with the `tlc-spec-driven` skill's Specify → Design → Tasks → Execute flow. Read `.specs/project/PROJECT.md`, `PRD.md`, `ARCHITECTURE.md`, and `ROADMAP.md` before making any planning or design decision — they encode already-resolved product and architecture choices that should not be re-derived or contradicted.

- **`.specs/project/`** — cross-cutting docs: `PROJECT.md` (vision/scope/stack), `PRD.md` (requirements), `ARCHITECTURE.md` (system design — auth, API conventions, data models, state machines, security, conventions; living doc, extended not replaced), `ROADMAP.md` (milestones and status).
- **`.specs/features/<feature-name>/`** — one `spec.md` + `design.md` per feature (`event-discovery`, `auth-fan-profile`, `venue-promoter-admin`, `favorites-social`, `notifications`, `monetization`). Each `design.md` references `ARCHITECTURE.md` instead of re-deriving cross-cutting decisions.

### Key architecture decisions that constrain all future work (see ARCHITECTURE.md for full detail)

- **Auth**: Laravel Sanctum, split by client — bearer tokens for mobile, httpOnly SPA cookies for web/admin/landing. Two separate guards (fan vs. venue/promoter/admin) — never a shared credential space. Never a token in `localStorage`/`sessionStorage`.
- **API routes**: `/api/v1/...` (end-user) vs `/api/admin/v1/...` (admin) is a hard boundary — separate route groups and Sanctum guards, not just a naming convention.
- **Clean Architecture is mandatory** for `qor-api` and `qor-mobile`'s shared KMP module — domain layer has zero framework dependency. `qor-api`'s `app/` is renamed `src/`, namespaced `QOR\App\` (PHP 8.4).
- **No magic strings/numbers**: every enum is a PHP backed enum (`qor-api`) mirrored as a TS union/const or Kotlin `enum class` per client; every numeric threshold lives in `config/qor.php`, never inlined. `City` is a fixed enum (4 cities); `Genre` is a DB-backed lookup table (ops-editable). Full list in ARCHITECTURE.md §14.
- **TDD mandatory, minimum 80% coverage** enforced as a CI gate per repo. **Test names use uppercase `GIVEN`/`WHEN`/`THEN`.**
- **Git workflow**: one long-lived branch per ROADMAP.md milestone; one Conventional Commit per Tasks-phase task; `qor-mobile` splits commits per platform boundary (shared/android/ios never mixed in one commit). Milestones are strictly sequential across the whole project — the next milestone cannot start in any submodule until the current one's PR(s) are merged.
- **Review-before-merge**: after a milestone's PR is opened, run the matching reviewer subagent (`review-laravel-api`, `review-react-web`, `review-kmp-android`, `review-ios-swift` — defined in `.claude/agents/`) before merge. Fixes are applied silently, no code comments referencing the review.
- **Localization**: every user-facing string (API errors, UI, push/email copy) is Brazilian Portuguese (pt-BR).
- **GA4 analytics**: event names follow `event:page:event-name`. A tracking spreadsheet must be reviewed and explicitly approved by the user before any GA4 event is implemented — never start that implementation unprompted.

## Design system

`design-system.md` at the root specifies **NIGHTLIFE-GV**, the product's dark, high-contrast design system (near-black nightlife base + four vibrant accent colors — pink/orange/purple/blue; Space Grotesk for display, Inter for body). UI work on **mobile, website, and the landing page** should conform to these tokens rather than inventing new ones.

The **admin panel** (`qor-admin`) is the one exception: it uses its own, separate design system — **`design-system-admin.md`** at the root — fully adopted from the BootstrapDash "Corona React" demo (its own colors, typography, spacing, and motion, not NIGHTLIFE-GV's). See `.specs/tasks/admin.md` for how this is applied task-by-task.

- `design-system-research/` holds competitive design-system teardowns (tokens.json/variables.css/notes per reference site) that NIGHTLIFE-GV was synthesized from, plus the `corona-react-admin/` subfolder (superseded by `design-system-admin.md` — see that folder's own notice) — useful background, not itself normative.
- `design-system-porpose/` and the root `Nightlife-GV Showcase.dc.html` are Claude-Design canvas artifacts (`.dc.html` + `support.js`) showcasing the design system and sample screens (Home Maré variants). These are visual references/prototypes, not application code.

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues (`github.com/derlandyb/QOR`), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root (lazily created), alongside the existing `.specs/` planning tree. See `docs/agents/domain.md`.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

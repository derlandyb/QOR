# State

**Last Updated:** 2026-08-28
**Current Work:** MVP Core — `api` submodule Phase 2 (domain layer) merged; `mobile`/`admin`/`website`/`landingpage` not yet started.

---

## Recent Decisions (Last 60 days)

### AD-001: Local dev orchestration via docker-compose + Makefile (2026-08-27)

**Decision:** Root repo provides a `docker-compose.yml` and `Makefile` to orchestrate local dev services across submodules.
**Reason:** Each submodule (api, mobile, admin, website, landingpage) needs a consistent way to spin up its dependencies without duplicating orchestration logic per repo.
**Trade-off:** Adds a root-level infra surface that must stay in sync as submodules add new services.
**Impact:** New services (e.g. databases, object storage) get wired into the root compose file as they're introduced.

### AD-002: PostgreSQL confirmed as the database (2026-08-27)

**Decision:** PostgreSQL is the system-of-record database for `qor-api`.
**Reason:** Confirmed and documented in ARCHITECTURE.md as the resolved choice for the project.
**Trade-off:** None recorded beyond the standard Postgres operational profile.
**Impact:** All Eloquent migrations, repository adapters, and CI test setup target Postgres.

### AD-003: Sanctum dual-guard split + versioned route groups (2026-08-27)

**Decision:** `qor-api` uses two separate Sanctum guards (fan vs. venue/promoter/admin) and a hard route-group boundary — `/api/v1/...` for end users, `/api/admin/v1/...` for admin — never a shared credential space.
**Reason:** Per ARCHITECTURE.md's auth model; fans and organizers/admins have distinct trust boundaries and must never share tokens or route groups.
**Trade-off:** More boilerplate (two guards, two route groups) than a single unified auth scheme.
**Impact:** Every new endpoint must be classified into one of the two guards/route groups at creation time — established in api PR #1 (`feat/mvp-core`).

### AD-004: MinIO as local S3-compatible object store (2026-08-28)

**Decision:** Root `docker-compose.yml` adds a MinIO service for local dev, standing in for S3.
**Reason:** `qor-api`'s new `S3UploadAdapter` (api PR #2) needs an S3-compatible target for local development without requiring real AWS credentials.
**Trade-off:** MinIO's API surface isn't a perfect match for S3 — edge cases may diverge in production.
**Impact:** Local dev and CI can exercise upload flows without cloud dependencies.

### AD-005: Clean Architecture domain layer landed for core entities (2026-08-28)

**Decision:** `qor-api`'s domain layer (entities, repository interfaces + Eloquent adapters, policies) now covers User, Venue, Promoter, Event (with state-machine enforcement), EventPromoter pivot, ApprovalDecision, and ConsentRecord.
**Reason:** Per CLAUDE.md's mandatory Clean Architecture rule — domain layer must have zero framework dependency; this is the first substantial slice landing that structure (api PR #2, `feat/api-domain-repositories-policies`).
**Trade-off:** More indirection (interfaces + adapters) than calling Eloquent models directly.
**Impact:** CI green at merge: 86 tests, 98.6% coverage, PHPStan level 9, `composer audit` clean. Sets the pattern future domain entities should follow.

### AD-006: Reviewer subagents required before submodule PR merge (2026-08-28)

**Decision:** `.claude/agents/` now defines `review-laravel-api`, `review-react-web`, `review-kmp-android`, `review-ios-swift` — one must run against a submodule's PR before it's merged.
**Reason:** Per CLAUDE.md's "Review-before-merge" rule; each submodule has its own stack and conventions that a single generic reviewer wouldn't catch consistently.
**Trade-off:** Adds a manual gate step between PR-open and merge in every submodule.
**Impact:** Fixes found in review are applied silently, with no code comments referencing the review.

---

## Active Blockers

_None currently open._

---

## Lessons Learned

### L-001: Mass-assignment vulnerability caught before api PR #1 merge (2026-08-27)

**Context:** During `qor-api`'s initial MVP scaffold (`feat/mvp-core`), a model exposed privilege fields to mass-assignment, and a dead frontend scaffold was left in the tree.
**Problem:** Both were caught during review, not before the branch was opened — mass-assignment on privilege fields is a real escalation risk if merged.
**Solution:** Fixed in a dedicated commit (`13c5d88`) before merge; `c4f5673` merged clean.
**Prevents:** `review-laravel-api` should explicitly check `$fillable`/`$guarded` on any model touching roles, approval status, or account state — this is now a standing check, not a one-off catch.

---

## Quick Tasks Completed

| #   | Description | Date | Commit | Status |
| --- | ------------ | ---- | ------ | ------ |

_None yet — no ad-hoc quick-mode tasks recorded._

---

## Deferred Ideas

_None captured yet._

---

## Todos

- [ ] `mobile`, `admin`, `website`, `landingpage` submodules have no feature work yet (README-only) — next up per ROADMAP.md once `api`'s domain layer stabilizes.
- [ ] CLAUDE.md's repository-topology note ("none of which are checked out yet") is stale — all 5 submodules are already checked out. Correct in a future pass.

---

## Preferences

**Model Guidance Shown:** never

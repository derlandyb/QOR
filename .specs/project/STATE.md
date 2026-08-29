# State

**Last Updated:** 2026-08-28
**Current Work:** MVP Core — `api` submodule Phase 3 complete: Event Discovery (PR #3), Auth & Fan Profile (PR #4), Venue/Promoter Admin (PR #5) all merged. Phase 4 (P2 stretch: EditEvent/DuplicateEvent/CancelEvent, promoter tagging, venue/promoter profile management, dashboard, account suspension enum verification, Postman collection, k6 load test, coverage gate) and Phase 5+ (Social & Notifications milestone) not started. `mobile`/`admin`/`website`/`landingpage` submodules not yet started.

---

## Recent Decisions (Last 60 days)

### AD-007: Phase 3 split into three sequential PRs, two infra gaps filled framework-natively (2026-08-28)

**Decision:** `qor-api` Phase 3 (T23–T43) ships as three sequential branches/PRs — Event Discovery (merged, PR #3), Auth & Fan Profile (merged, PR #4), Venue/Promoter Admin (in progress). Two gaps Phase 2 left open are filled with Laravel-native mechanisms behind domain ports rather than custom builds: `AdminAccountRepository` for the admin login row created alongside Venue/Promoter registration, and email-verification/password-reset via signed URLs + the stock `password_reset_tokens` broker (`EmailVerificationPort`/`PasswordResetPort`).
**Reason:** Keeps each PR reviewable and mergeable independently (milestones are sequential per CLAUDE.md); avoids inventing new custom mechanisms where Laravel already has a fitting one.
**Trade-off:** Three review passes instead of one; the admin-login-row gap-fill adds one more domain entity/repository pair not in the original Phase 2 scope.
**Impact:** PR #4's `review-laravel-api` pass caught and fixed two issues before merge: `EloquentUserRepository::delete()` was a plain soft-delete without PII scrub (violated the LGPD "right to be forgotten" design decision — fixed), and the email-verification link TTL was hardcoded instead of config-driven (fixed, added `qor.auth.email_verification_ttl_minutes`). PR #5 (Venue/Promoter Admin, T34–T43) added a second gap-fill (`AdminAccountRepository`, per AD-007's plan) plus `ApprovalOutcome::SuspensionLifted` (missing from Phase 2 despite ADMIN-27 needing it), an `EnsureSuperAdmin` guard restricting the two approval-queue controllers, and a `DomainException`→422 global exception mapping (illegal `Event` state-machine transitions previously had no HTTP mapping and would have 500'd). Its review pass fixed one issue: `RegisterPromoter` could leave a dangling `AdminAccount` row if the `Promoter` entity's own field validation failed after the account was already saved — `RegisterVenue` already guarded against this via a throwaway pre-validation construction; `RegisterPromoter` was missing the same guard. `EditEvent`/`DuplicateEvent`/`CancelEvent` and their `PATCH`/duplicate/cancel routes are deliberately deferred to Phase 4 (T44) — not implemented in PR #5. CAPTCHA (ARCHITECTURE §13.2) remains deferred — see Todos.

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
- [x] CLAUDE.md's repository-topology note ("none of which are checked out yet") was stale — all 5 submodules are already checked out. Fixed 2026-08-28.
- [ ] CAPTCHA (ARCHITECTURE §13.2) not implemented on any public unauthenticated form (fan signup, password-reset request, venue/promoter registration) — no provider chosen yet, not in PRD's resolved decisions. Needs a follow-up task once a vendor is picked.
- [ ] Google ID token is trusted client-side (`POST /api/v1/auth/google` accepts `google_id`/`email`/`name` as-is) — server-side verification via Google's token library isn't wired up. Flagged in `GoogleAuthRequest`'s docblock (api PR #4).
- [x] Venue/Promoter/Super Admin login (ADMIN-28–30) — Tasks/Execute closed 2026-08-28 on branch `feat/api-admin-login` (T1–T4, T6): `AuthenticateAdmin` use case, admin `LoginRequest`, `AdminAuthController` (`POST /api/admin/v1/auth/login`, `POST /api/admin/v1/auth/logout`) wired into the existing `admin` guard/`AdminAccountRepository`/`AdminUserModel`/`EnsureAdminIdentity` infra from PR #5. 354 tests passing, 98.5% coverage, phpstan clean. T7 (`review-laravel-api`) pending PR open.
- [ ] Admin password recovery (forgot/reset password for Venue Admin/Promoter/Super Admin) is unspecified — `auth-fan-profile`'s `ResetPassword`/`password_reset_tokens` flow only covers fans. Not yet requested; flagged alongside the login gap for a future Specify pass if needed.
- [ ] `qor-admin` has no Next.js scaffold yet (only `README.md`) — the admin-panel login UI, and every other frontend piece of `venue-promoter-admin`, needs a bootstrap pass (Next.js + `design-system-admin.md` tokens) before it can be Specified/Tasked as its own slice.

---

## Preferences

**Model Guidance Shown:** never

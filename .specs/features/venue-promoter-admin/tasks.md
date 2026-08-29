# Venue/Promoter Admin — Tasks: Admin Login (ADMIN-28–30)

**Spec**: `.specs/features/venue-promoter-admin/spec.md`
**Design**: `.specs/features/venue-promoter-admin/design.md`
**Status**: Draft

**Scope note**: This tasks.md covers only the admin-login slice (ADMIN-28, ADMIN-29, ADMIN-30) —
the one piece of `venue-promoter-admin` that is Spec-closed and Design-closed but never reached
Tasks/Execute (see `.specs/project/STATE.md` Todos). Everything else in the feature (registration,
event CRUD, approval queues, dashboard) was already implemented directly in PR #5 without a
committed tasks.md and is out of scope here.

**Stack**: `qor-api` (Laravel) only. `qor-admin` (Next.js) has no scaffold yet — see T6's Done When
for the STATE.md todo this creates. No other stack is touched by this slice.

---

## Execution Plan

### Phase 1: Foundation (Parallel)

```
T1 [P] ── T3 [P]
```

### Phase 2: Domain (Sequential, depends on T1)

```
T1 → T2
```

### Phase 3: HTTP + Routes (Sequential, depends on T2 and T3)

```
T2, T3 → T4
```

### Phase 4: Gate + PR + Review (Sequential, depends on T4)

```
T4 → T6 → (open PR) → T7
```

---

## Task Breakdown

### T1: Create `AdminAccount` invalid-credentials exception [P]

**What**: New domain exception class for admin-login failures, own namespace (not reused from the fan domain).
**Where**: `api/src/Domain/Admin/Exception/InvalidCredentials.php`
**Depends on**: None
**Reuses**: `api/src/Domain/User/Exception/InvalidCredentials.php` (identical shape)
**Requirement**: ADMIN-29

**Tools**:
- MCP: NONE
- Skill: `laravel-specialist` (or NONE — trivial)

**Done when**:
- [ ] `final class InvalidCredentials extends InvalidArgumentException {}` in namespace `QOR\App\Domain\Admin\Exception`
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: none (matches fan-side precedent — no dedicated test for the equivalent marker class)
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`

**Commit**: `feat(api): add admin InvalidCredentials exception`

---

### T2: Create `AuthenticateAdmin` use case

**What**: Domain use case that authenticates a Venue Admin/Promoter/Super Admin by email+password, with no verified/approval-status gate (login succeeds regardless of `approval_status`).
**Where**: `api/src/Domain/Admin/UseCase/AuthenticateAdmin.php`
**Depends on**: T1
**Reuses**: `AdminAccountRepository::findByEmail` (already bound in `AppServiceProvider.php:50`), `PasswordHasher` interface (already bound at `AppServiceProvider.php:53`), shape of `api/src/Domain/User/UseCase/AuthenticateFan.php::executeWithPassword`
**Requirement**: ADMIN-28, ADMIN-29

**Tools**:
- MCP: NONE
- Skill: `laravel-specialist`

**Done when**:
- [ ] `executeWithPassword(string $email, string $password): AdminAccount` implemented
- [ ] Looks up account via `AdminAccountRepository::findByEmail`
- [ ] Verifies password via `PasswordHasher::verify`
- [ ] Throws `Domain\Admin\Exception\InvalidCredentials('Credenciais inválidas')` on unknown email OR wrong password (identical message either way — no email-exists leakage)
- [ ] Does NOT check any verified/approval-status field — login succeeds for `Pending Approval`/`Approved`/`Rejected`/suspended accounts alike
- [ ] Gate check passes: `php artisan test --filter=AuthenticateAdminTest`
- [ ] Test count: 3 tests pass (no silent deletions)

**Tests**: unit — `api/tests/Unit/Domain/Admin/UseCase/AuthenticateAdminTest.php`
- `test_GIVEN_correct_credentials_WHEN_authenticating_THEN_it_returns_the_account`
- `test_GIVEN_a_wrong_password_WHEN_authenticating_THEN_it_rejects_with_a_generic_message`
- `test_GIVEN_an_unknown_email_WHEN_authenticating_THEN_it_rejects_with_the_same_generic_message`

Mirror `api/tests/Unit/Domain/User/UseCase/AuthenticateFanTest.php`'s Mockery pattern (mock `AdminAccountRepository`, mock `PasswordHasher`) — omit the fan test's unverified-account case, it doesn't apply here.

**Gate**: quick — `php artisan test --filter=AuthenticateAdminTest`

**Commit**: `feat(api): add AuthenticateAdmin use case`

---

### T3: Create admin `LoginRequest` [P]

**What**: Form Request validating admin-login payload (email, password), pt-BR messages.
**Where**: `api/src/Http/Requests/Api/AdminV1/LoginRequest.php`
**Depends on**: None
**Reuses**: `api/src/Http/Requests/Api/V1/Auth/LoginRequest.php` (identical rules/messages, different namespace)
**Requirement**: ADMIN-28, ADMIN-29

**Tools**:
- MCP: NONE
- Skill: `laravel-specialist`

**Done when**:
- [ ] `rules()`: `email` required+email, `password` required+string
- [ ] `messages()`: pt-BR — "O e-mail é obrigatório.", "E-mail inválido.", "A senha é obrigatória."
- [ ] `authorize()` returns `true` (public endpoint)
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: none (covered via T4's controller Feature tests — matches fan-side precedent, no standalone FormRequest test exists there either)
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`

**Commit**: `feat(api): add admin LoginRequest`

---

### T4: Create `AdminAuthController` (login + logout) and wire routes

**What**: HTTP boundary for admin login/logout under `/api/admin/v1/auth/*`, mirroring `AuthController::login/logout` exactly (try/catch → 401 remap, bearer-token session response). Includes the ADMIN-30 guard-isolation regression tests (no new production code for isolation — proves the already-merged `EnsureAdminIdentity`/`guard.admin` middleware rejects cross-guard tokens).
**Where**:
- `api/src/Http/Controllers/Api/AdminV1/AdminAuthController.php` (new)
- `api/routes/api_admin_v1.php` (modify — add two routes)

**Depends on**: T2, T3
**Reuses**: `api/src/Http/Controllers/Api/V1/AuthController.php::login` (lines 53–67) and `::logout` (lines 86–94) control flow; `AdminUserModel::createToken` (same `HasApiTokens` trait as `UserModel`)
**Requirement**: ADMIN-28, ADMIN-29, ADMIN-30

**Tools**:
- MCP: NONE
- Skill: `laravel-specialist`

**Done when**:
- [ ] `login(LoginRequest $request): JsonResponse` — calls `AuthenticateAdmin::executeWithPassword`; catches `InvalidCredentials` → `response()->json(['message' => $e->getMessage()], 401)`; success → `response()->json(['data' => [...account fields...], 'token' => AdminUserModel::findOrFail($account->id)->createToken('admin')->plainTextToken])`
- [ ] `logout(Request $request): JsonResponse` — `$request->user()->currentAccessToken()->delete()`, returns `{message: 'Sessão encerrada.'}`
- [ ] Route added: `POST /auth/login` inside the existing `throttle:qor-auth` group in `api_admin_v1.php` (alongside `/venues/register`, `/promoters/register`)
- [ ] Route added: `POST /auth/logout` inside the existing `['auth:admin', 'guard.admin']` group in `api_admin_v1.php`
- [ ] Gate check passes: `php artisan test --filter=AdminAuthControllerTest`
- [ ] Test count: 7 tests pass (no silent deletions)

**Tests**: integration (Feature, `RefreshDatabase`) — `api/tests/Feature/Http/Controllers/Api/AdminV1/AdminAuthControllerTest.php`
- `test_GIVEN_correct_credentials_for_a_pending_approval_account_WHEN_logging_in_THEN_it_returns_a_token` (ADMIN-28 — the key case distinguishing admin from fan login)
- `test_GIVEN_correct_credentials_for_an_approved_account_WHEN_logging_in_THEN_it_returns_a_token` (ADMIN-28)
- `test_GIVEN_correct_credentials_for_a_rejected_or_suspended_account_WHEN_logging_in_THEN_it_returns_a_token` (ADMIN-28)
- `test_GIVEN_the_wrong_password_WHEN_logging_in_THEN_it_returns_401_with_a_generic_message` (ADMIN-29)
- `test_GIVEN_an_unknown_email_WHEN_logging_in_THEN_it_returns_401_with_the_same_generic_message` (ADMIN-29)
- `test_GIVEN_an_authenticated_admin_WHEN_logging_out_THEN_the_token_is_revoked`
- `test_GIVEN_a_fan_token_WHEN_calling_an_admin_guarded_route_THEN_it_is_rejected` and/or `test_GIVEN_an_admin_token_WHEN_calling_a_fan_guarded_route_THEN_it_is_rejected` (ADMIN-30 — asserts against existing `EnsureAdminIdentity`/`guard.admin`, no new isolation code)

**Gate**: quick — `php artisan test --filter=AdminAuthControllerTest`

**Commit**: `feat(api): add admin auth login/logout endpoints`

---

### T6: Full gate, requirement traceability, and STATE.md todo

**What**: Run the full CI-equivalent gate, close out the requirement-traceability rows this slice satisfies, and record the qor-admin scaffolding gap this slice surfaces.
**Where**: `.specs/features/venue-promoter-admin/spec.md` (Requirement Traceability table), `.specs/project/STATE.md` (Todos)
**Depends on**: T4 (which folds T5's guard-isolation tests)
**Requirement**: ADMIN-28, ADMIN-29, ADMIN-30

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M --error-format=github` clean
- [ ] `php artisan test --coverage --min=80` passes
- [ ] `spec.md` Requirement Traceability rows for ADMIN-28/29/30 updated: mapped to T2 (`AuthenticateAdmin`) and T4 (`AdminAuthController`), status flipped from "In Design"/unmapped to "Done"; coverage summary line updated (30 total, 3 now mapped, 27 unmapped)
- [ ] `STATE.md` Todos gains an entry: `qor-admin` has no Next.js scaffold yet (only `README.md`) — the admin-panel login UI, and every other frontend piece of `venue-promoter-admin`, needs a bootstrap pass (Next.js + `design-system-admin.md` tokens) before it can be Specified/Tasked as its own slice

**Tests**: none (gate/docs task)
**Gate**: full — `php artisan test --coverage --min=80` (matches `api/.github/workflows/api-ci.yml:103`)

**Commit**: `docs(venue-promoter-admin): close ADMIN-28-30 traceability, flag qor-admin scaffolding gap`

---

### T7: Review-before-merge — `review-laravel-api`

**What**: After the PR for this slice is opened, run the `review-laravel-api` reviewer subagent against it per CLAUDE.md's Review-before-merge rule. Post its findings as a PR comment, then triage: apply valid fixes silently (no code comments referencing the review), push a follow-up commit, and update the PR. Note any false positive or explicitly out-of-scope finding in the PR thread instead of the code.
**Where**: PR for this branch/slice (GitHub); any files the review flags
**Depends on**: T6 (PR must be open, containing T1–T4/T6's commits)
**Requirement**: N/A (process gate, not a spec requirement)

**Tools**:
- MCP: NONE
- Skill: NONE (invoke `review-laravel-api` agent directly)

**Done when**:
- [ ] `review-laravel-api` run against the open PR
- [ ] Findings posted as a comment on the PR
- [ ] Every finding triaged: fixed (with a follow-up commit) or explicitly noted as declined/out-of-scope in the PR thread
- [ ] If any fix commit was pushed: `vendor/bin/phpstan analyse --memory-limit=512M` and `php artisan test --coverage --min=80` re-run and passing
- [ ] PR updated/pushed with final state

**Tests**: re-run T4/T6's suites if fixes are applied
**Gate**: full — `php artisan test --coverage --min=80`

**Commit**: `fix(api): address review-laravel-api findings on admin login PR` (only if fixes are needed)

---

## Parallel Execution Map

```
Phase 1 (Parallel):
  T1 [P] ── T3 [P]

Phase 2 (Sequential):
  T1 complete, then:
    T2

Phase 3 (Sequential):
  T2, T3 complete, then:
    T4

Phase 4 (Sequential):
  T4 complete, then:
    T6 ──→ (open PR) ──→ T7
```

**Parallelism constraint check**: T1 and T3 touch disjoint files (`Domain/Admin/Exception/InvalidCredentials.php` vs `Http/Requests/Api/AdminV1/LoginRequest.php`), neither has tests requiring shared DB state, no shared mutable state — both are `[P]`-safe.

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|------|------------------------|----------------|--------|
| T1 | None | None | ✅ Match |
| T2 | T1 | T1 → T2 | ✅ Match |
| T3 | None | None | ✅ Match |
| T4 | T2, T3 | T2, T3 → T4 | ✅ Match |
| T6 | T4 | T4 → T6 | ✅ Match |
| T7 | T6 | T6 → T7 | ✅ Match |

---

## Test Co-location Validation

No `.specs/codebase/TESTING.md` exists yet (greenfield for this repo's Tasks-phase tooling); test types below are inferred directly from the existing fan-side reference implementation's test layout (`AuthenticateFanTest` = unit, `AuthControllerTest` = Feature/integration), which is the established convention in this codebase.

| Task | Code Layer Created/Modified | Convention Requires | Task Says | Status |
|------|------------------------------|----------------------|-----------|--------|
| T1: InvalidCredentials exception | Domain exception (marker class) | none (fan-side precedent) | none | ✅ OK |
| T2: AuthenticateAdmin | Domain use case | unit | unit | ✅ OK |
| T3: LoginRequest | Http Form Request | none (covered by controller Feature test) | none | ✅ OK |
| T4: AdminAuthController + routes | Http controller + routes | integration (Feature) | integration | ✅ OK |
| T6: Gate + traceability | docs/gate only | none | none | ✅ OK |
| T7: Review-before-merge | process gate, possible fix commits | re-run existing suites | re-run existing suites | ✅ OK |

---

## Tips (from skill template — kept for Execute-phase reference)

- **[P] = Parallel OK** — T1 and T3 run via concurrent sub-agents
- **Reuses = Token saver** — every task above cites its fan-side/existing-code mirror
- **One commit per task** — T1–T4, T6 each get one Conventional Commit; T7 gets zero or more fix commits
- **Requirement ID = Traceable** — every task maps to ADMIN-28/29/30

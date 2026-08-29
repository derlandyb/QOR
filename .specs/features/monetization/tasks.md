# Monetization — Tasks: Publishing Plans & Quota Enforcement (MON-01–MON-18, P1)

**Spec**: `.specs/features/monetization/spec.md`
**Design**: `.specs/features/monetization/design.md`
**Status**: Draft

**Scope note**: P1 only (MON-01–MON-18) — the plan/subscription/quota loop. P2 (MON-19–MON-26 —
plan upgrade/downgrade, cancellation, annual billing cycle) is deferred per the design's own scope
note; the `Plan`/`Subscription` schema still includes the P2 fields (`annual_price`,
`billing_cycle`) per ARCHITECTURE.md §4 so no later migration is needed to add them.

**Stack**: `qor-api` (Laravel) only. `qor-admin` (Plan CRUD UI, organizer usage widget) and
`qor-landingpage` (plan comparison page) have no scaffold yet — same precedent as the admin-login
slice, which shipped API-only ahead of `qor-admin`.

---

## Execution Plan

### Phase 1: Foundation (Parallel)

```
T1 [P] ── T2 [P] ── T3 [P] ── T4 [P]
```

### Phase 2: Domain entities (Parallel, depends on T1–T4 conceptually but framework-free)

```
T1, T2 → T5 [P] ── T6 [P]
```

### Phase 3: Repositories + models (depends on T3/T4 migrations, T5/T6 entities)

```
T3, T5 → T7 [P] ── T8 [P] (T4, T6 → T8)
T7, T8 → T9
```

### Phase 4: Use cases (depends on T9)

```
T9 → T10 [P] ── T11 [P] ── T12 [P] ── T13 [P] ── T14 [P] ── T15 [P] ── T16 [P] ── T17 [P]
```

### Phase 5: Extension points (depends on T14, T15)

```
T14 → T18
T15 → T19
```

### Phase 6: HTTP layer (depends on Phase 4 use cases)

```
T10 → T20
T11, T12, T13 → T21
T17 → T22
```

### Phase 7: Scheduler + seeder (depends on T16, T7)

```
T16 → T23
T7 → T24
```

### Phase 8: Gate + PR + Review (Sequential, depends on all above)

```
T18, T19, T20, T21, T22, T23, T24 → T25 → T26 → (open PR) → T27
```

---

## Task Breakdown

### T1: Add `qor.billing.default_free_quota` config key [P]

**What**: New config section for billing constants, per ARCHITECTURE.md §14.2 — the seeded free
plan's quota (5) is read from here, never hardcoded in a use case.
**Where**: `api/config/qor.php` (add a `billing` section)
**Depends on**: None
**Reuses**: existing `config/qor.php` section pattern (e.g. `notifications`, `auth`)
**Requirement**: MON-04 (indirectly — the seeder that uses this key is T24)

**Tools**: Skill: `laravel-specialist` (or NONE — trivial)

**Done when**:
- [ ] `'billing' => ['default_free_quota' => (int) env('QOR_DEFAULT_FREE_QUOTA', 5)]` added to `config/qor.php`
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: none (config-only, matches precedent — no config file has a dedicated test)
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`
**Commit**: `feat(api): add default free-plan quota config key`

---

### T2: Create Billing enums [P]

**What**: Backed enums per ARCHITECTURE.md §14.1: `SubscribableType` (`Venue`, `Promoter`),
`SubscriptionStatus` (`Active`, `CancelledPendingReset`), `BillingCycle` (`Monthly`, `Annual`).
**Where**: `api/src/Domain/Billing/Enum/SubscribableType.php`, `.../Enum/SubscriptionStatus.php`, `.../Enum/BillingCycle.php`
**Depends on**: None
**Reuses**: `src/Domain/Approval/Enum/ApprovalStatus.php` (shape/style reference — backed string enum)
**Requirement**: MON-04, MON-24–MON-26 (schema-level; P2 cases not enforced yet)

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] Three backed string enums exist under `QOR\App\Domain\Billing\Enum`
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: none (matches precedent — no dedicated test exists for other enum classes)
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`
**Commit**: `feat(api): add Billing domain enums`

---

### T3: Migration — `plans` table [P]

**What**: `plans` table per ARCHITECTURE.md §4: `id, name, monthly_price, annual_price (nullable),
publish_quota (nullable = unlimited), is_active, is_default_free, created_at, updated_at`.
**Where**: `api/database/migrations/2026_08_29_010000_create_plans_table.php`
**Depends on**: None
**Reuses**: `database/migrations/2026_08_28_020400_create_approval_decisions_table.php` (style reference)
**Requirement**: MON-13–MON-16

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] Columns match ARCHITECTURE.md §4 exactly; `monthly_price`/`annual_price` as `decimal(10,2)`
- [ ] `publish_quota` nullable integer (null = unlimited, per MON-10)
- [ ] `is_active` boolean default true, `is_default_free` boolean default false
- [ ] `php artisan migrate:fresh` runs clean in the test DB

**Tests**: none (migration-only)
**Gate**: `php artisan migrate:fresh` (local/test DB)
**Commit**: `feat(api): add plans table migration`

---

### T4: Migration — `subscriptions` table [P]

**What**: `subscriptions` table per ARCHITECTURE.md §4: `id, subscribable_type, subscribable_id
(polymorphic), plan_id (FK), status, billing_cycle (nullable), current_period_start,
current_period_end, publishes_used_this_period, created_at, updated_at`.
**Where**: `api/database/migrations/2026_08_29_010100_create_subscriptions_table.php`
**Depends on**: None (references `plans.id` at migration-apply time, not authoring time — matches
existing FK-migration-ordering precedent since Laravel resolves FKs at `migrate` time by filename order,
so this migration's timestamp must sort after T3's)
**Reuses**: `database/migrations/2026_08_28_020400_create_approval_decisions_table.php` (polymorphic
`decidable_type`/`decidable_id` pattern, reused here as `subscribable_type`/`subscribable_id`)
**Requirement**: MON-04, MON-07–MON-12

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `subscribable_type` string, `subscribable_id` unsignedBigInteger, indexed together (mirrors `approval_decisions`)
- [ ] `plan_id` foreign key constrained to `plans`
- [ ] `publishes_used_this_period` unsignedInteger default 0
- [ ] `php artisan migrate:fresh` runs clean in the test DB

**Tests**: none (migration-only)
**Gate**: `php artisan migrate:fresh` (local/test DB)
**Commit**: `feat(api): add subscriptions table migration`

---

### T5: `Plan` domain entity [P]

**What**: Framework-free domain entity (Clean Architecture §8.5 — no Eloquent import).
**Where**: `api/src/Domain/Billing/Plan.php`
**Depends on**: T1 (none functionally, but co-located under the same namespace T2 establishes)
**Reuses**: `src/Domain/Venue/Venue.php` (readonly-property entity shape reference)
**Requirement**: MON-13–MON-16

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] Readonly properties: `id (?int), name, monthlyPrice, annualPrice (?float), publishQuota (?int),
  isActive, isDefaultFree`
- [ ] No `Illuminate\*` or `QOR\App\Infrastructure\*` imports
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: none (matches precedent — plain data entities like `Venue`/`Promoter` have no dedicated unit test)
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`
**Commit**: `feat(api): add Plan domain entity`

---

### T6: `Subscription` domain entity [P]

**What**: Framework-free domain entity with the one piece of real behavior this feature needs:
whether a submission is currently allowed.
**Where**: `api/src/Domain/Billing/Subscription.php`
**Depends on**: T2 (uses `SubscribableType`, `SubscriptionStatus`)
**Reuses**: `src/Domain/Event/Event.php` (entity-with-behavior shape reference — e.g. `transitionTo`)
**Requirement**: MON-07–MON-12

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] Readonly properties: `id (?int), subscribableType, subscribableId, planId, status,
  billingCycle (?BillingCycle), currentPeriodStart, currentPeriodEnd, publishesUsedThisPeriod`
- [ ] No `Illuminate\*` imports
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: unit — `api/tests/Unit/Domain/Billing/SubscriptionTest.php` if any entity-level behavior is
added beyond plain data (e.g. a `withIncrementedUsage()` immutable-update helper used by T15); if the
entity stays plain data with all logic in the use case, skip per the `Plan`/T5 precedent
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`
**Commit**: `feat(api): add Subscription domain entity`

---

### T7: `PlanRepository` interface + `PlanModel` + `EloquentPlanRepository` [P]

**What**: Repository interface, Eloquent model, and adapter for `Plan`.
**Where**: `api/src/Domain/Billing/PlanRepository.php`, `api/src/Infrastructure/Persistence/Eloquent/PlanModel.php`, `api/src/Infrastructure/Persistence/EloquentPlanRepository.php`
**Depends on**: T3, T5
**Reuses**: `src/Domain/Venue/VenueRepository.php` + `src/Infrastructure/Persistence/EloquentVenueRepository.php` (interface/adapter shape reference)
**Requirement**: MON-01–MON-03, MON-13–MON-16

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] Interface methods: `findById(int): ?Plan`, `findActive(): Plan[]`, `findDefaultFree(): ?Plan`, `save(Plan): Plan`
- [ ] `PlanModel` guards mass-assignment explicitly (`$fillable`) — no privilege-adjacent field left open (L-001 precedent)
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors
- [ ] `php artisan test --filter=EloquentPlanRepositoryTest` passes

**Tests**: integration (Feature, `RefreshDatabase`) — `api/tests/Feature/Infrastructure/Persistence/EloquentPlanRepositoryTest.php`
- `test_GIVEN_an_active_and_an_inactive_plan_WHEN_finding_active_plans_THEN_only_the_active_one_is_returned` (MON-01, MON-03)
- `test_GIVEN_a_plan_flagged_default_free_WHEN_finding_the_default_free_plan_THEN_it_is_returned`
- `test_GIVEN_no_plan_flagged_default_free_WHEN_finding_the_default_free_plan_THEN_null_is_returned` (MON-05)

**Gate**: `php artisan test --filter=EloquentPlanRepositoryTest`
**Commit**: `feat(api): add PlanRepository and Eloquent adapter`

---

### T8: `SubscriptionRepository` interface + `SubscriptionModel` + `EloquentSubscriptionRepository` [P]

**What**: Repository interface, Eloquent model, and adapter for `Subscription`.
**Where**: `api/src/Domain/Billing/SubscriptionRepository.php`, `api/src/Infrastructure/Persistence/Eloquent/SubscriptionModel.php`, `api/src/Infrastructure/Persistence/EloquentSubscriptionRepository.php`
**Depends on**: T4, T6
**Reuses**: `src/Domain/Approval/ApprovalDecisionRepository.php` + its Eloquent adapter (polymorphic-lookup shape reference)
**Requirement**: MON-04, MON-07–MON-12

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] Interface methods: `findBySubscribable(SubscribableType, int): ?Subscription`, `save(Subscription): Subscription`, `all(): Subscription[]` (for T16's reset job)
- [ ] `SubscriptionModel` guards mass-assignment explicitly (`$fillable`)
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors
- [ ] `php artisan test --filter=EloquentSubscriptionRepositoryTest` passes

**Tests**: integration (Feature, `RefreshDatabase`) — `api/tests/Feature/Infrastructure/Persistence/EloquentSubscriptionRepositoryTest.php`
- `test_GIVEN_a_subscription_for_a_venue_WHEN_finding_by_subscribable_THEN_it_is_returned`
- `test_GIVEN_an_updated_usage_count_WHEN_saving_THEN_the_persisted_row_reflects_the_new_count`

**Gate**: `php artisan test --filter=EloquentSubscriptionRepositoryTest`
**Commit**: `feat(api): add SubscriptionRepository and Eloquent adapter`

---

### T9: Bind Billing repositories in `AppServiceProvider`

**What**: Register the two new interface→adapter bindings.
**Where**: `api/src/Providers/AppServiceProvider.php` (modify — add two `$this->app->bind(...)` lines alongside the existing ones, e.g. near line 78's `FavoriteRepository` binding)
**Depends on**: T7, T8
**Reuses**: existing binding block (lines 71–88)
**Requirement**: N/A (wiring)

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `PlanRepository::class => EloquentPlanRepository::class` and `SubscriptionRepository::class => EloquentSubscriptionRepository::class` bound
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M` passes with no new errors

**Tests**: none (covered transitively by T7/T8's Feature tests, which resolve the interface through the container)
**Gate**: `vendor/bin/phpstan analyse --memory-limit=512M`
**Commit**: `feat(api): bind Billing repositories in AppServiceProvider`

---

### T10: `ListActivePlans` use case [P]

**What**: MON-01–MON-03 — list every active plan for the public landing page.
**Where**: `api/src/Domain/Billing/UseCase/ListActivePlans.php`
**Depends on**: T9
**Reuses**: `src/Domain/Event/UseCase/ListUpcomingEvents.php` (list-use-case shape reference)
**Requirement**: MON-01–MON-03

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(): Plan[]` calls `PlanRepository::findActive()`
- [ ] `php artisan test --filter=ListActivePlansTest` passes (3 tests)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/ListActivePlansTest.php`
- `test_GIVEN_two_active_plans_and_one_inactive_WHEN_listing_THEN_only_active_plans_are_returned`
- `test_GIVEN_no_active_plans_WHEN_listing_THEN_an_empty_array_is_returned`
- `test_GIVEN_a_plan_is_deactivated_WHEN_listing_again_THEN_it_no_longer_appears` (MON-03)

**Gate**: `php artisan test --filter=ListActivePlansTest`
**Commit**: `feat(api): add ListActivePlans use case`

---

### T11: `CreatePlan` use case [P]

**What**: MON-13, MON-16 — Super Admin creates a plan.
**Where**: `api/src/Domain/Billing/UseCase/CreatePlan.php`
**Depends on**: T9
**Requirement**: MON-13, MON-16

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(name, monthlyPrice, publishQuota, ?annualPrice): Plan` saves a new active `Plan`
- [ ] Field-level validation (required name/monthlyPrice/publishQuota) lives in the Form Request (T21), not duplicated here — this use case trusts its inputs, per the domain-vs-boundary validation split established elsewhere in the codebase
- [ ] `php artisan test --filter=CreatePlanTest` passes (1 test)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/CreatePlanTest.php`
- `test_GIVEN_valid_plan_data_WHEN_creating_THEN_it_is_persisted_as_active`

**Gate**: `php artisan test --filter=CreatePlanTest`
**Commit**: `feat(api): add CreatePlan use case`

---

### T12: `UpdatePlan` use case [P]

**What**: MON-14 — edit price/quota without altering historical usage of existing subscribers.
**Where**: `api/src/Domain/Billing/UseCase/UpdatePlan.php`
**Depends on**: T9
**Requirement**: MON-14

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(planId, ...changedFields): Plan` updates only the `Plan` row — never touches `Subscription.publishes_used_this_period`
- [ ] Throws `InvalidArgumentException('Plano não encontrado.')` if `planId` doesn't exist
- [ ] `php artisan test --filter=UpdatePlanTest` passes (2 tests)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/UpdatePlanTest.php`
- `test_GIVEN_an_existing_plan_WHEN_updating_its_quota_THEN_existing_subscribers_usage_counts_are_unchanged` (MON-14)
- `test_GIVEN_an_unknown_plan_id_WHEN_updating_THEN_it_rejects_with_a_generic_message`

**Gate**: `php artisan test --filter=UpdatePlanTest`
**Commit**: `feat(api): add UpdatePlan use case`

---

### T13: `DeactivatePlan` use case [P]

**What**: MON-15 — hide from new signups without disturbing existing subscribers.
**Where**: `api/src/Domain/Billing/UseCase/DeactivatePlan.php`
**Depends on**: T9
**Requirement**: MON-15

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(planId): Plan` sets `is_active = false`; does not touch any `Subscription` row
- [ ] `php artisan test --filter=DeactivatePlanTest` passes (1 test)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/DeactivatePlanTest.php`
- `test_GIVEN_an_active_plan_with_a_subscriber_WHEN_deactivating_THEN_the_subscribers_subscription_is_untouched`

**Gate**: `php artisan test --filter=DeactivatePlanTest`
**Commit**: `feat(api): add DeactivatePlan use case`

---

### T14: `CreateSubscriptionOnApproval` use case [P]

**What**: MON-04–MON-06 — creates a `Subscription` on the default free plan when an account is approved; blocks with a configuration error if no plan is flagged default.
**Where**: `api/src/Domain/Billing/UseCase/CreateSubscriptionOnApproval.php`
**Depends on**: T9
**Reuses**: `src/Domain/Approval/UseCase/DecideAccountApproval.php` (the caller — extended in T18, not here)
**Requirement**: MON-04, MON-05, MON-06

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(SubscribableType, int $subscribableId): Subscription`
- [ ] Looks up the default-free plan via `PlanRepository::findDefaultFree()`
- [ ] Throws `InvalidArgumentException('Configure um plano gratuito padrão antes de aprovar contas.')` if none exists (MON-05)
- [ ] Sets `current_period_start`/`current_period_end` to the current calendar month, `publishes_used_this_period = 0`, `status = Active`
- [ ] `php artisan test --filter=CreateSubscriptionOnApprovalTest` passes (3 tests)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/CreateSubscriptionOnApprovalTest.php`
- `test_GIVEN_a_default_free_plan_exists_WHEN_creating_a_subscription_on_approval_THEN_it_is_created_on_that_plan_with_zero_usage` (MON-04, MON-06)
- `test_GIVEN_no_plan_is_flagged_default_free_WHEN_creating_a_subscription_on_approval_THEN_it_throws_a_configuration_error` (MON-05)
- `test_GIVEN_a_promoter_account_WHEN_creating_a_subscription_on_approval_THEN_the_subscribable_type_is_promoter`

**Gate**: `php artisan test --filter=CreateSubscriptionOnApprovalTest`
**Commit**: `feat(api): add CreateSubscriptionOnApproval use case`

---

### T15: `CheckAndIncrementQuota` use case [P]

**What**: MON-07–MON-10 — the actual monetization lever.
**Where**: `api/src/Domain/Billing/UseCase/CheckAndIncrementQuota.php`
**Depends on**: T9
**Reuses**: `src/Domain/Event/UseCase/SubmitEventForReview.php` (the caller — extended in T19, not here)
**Requirement**: MON-07, MON-08, MON-09, MON-10

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(SubscribableType, int $subscribableId): void`
- [ ] Under quota (or `publish_quota IS NULL`, MON-10): increments `publishes_used_this_period` and saves
- [ ] At quota: throws `InvalidArgumentException('Você atingiu o limite de publicações do seu plano.')`, does NOT increment (MON-08)
- [ ] Never called from any approval/rejection code path (MON-09 — enforced by T19's placement, not this use case)
- [ ] `php artisan test --filter=CheckAndIncrementQuotaTest` passes (4 tests)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/CheckAndIncrementQuotaTest.php`
- `test_GIVEN_usage_below_quota_WHEN_checking_and_incrementing_THEN_the_count_increments_by_one` (MON-07)
- `test_GIVEN_usage_at_quota_WHEN_checking_and_incrementing_THEN_it_blocks_and_the_count_is_unchanged` (MON-08)
- `test_GIVEN_an_unlimited_quota_plan_WHEN_checking_and_incrementing_THEN_it_never_blocks_regardless_of_usage` (MON-10)
- `test_GIVEN_usage_exactly_one_below_quota_WHEN_checking_and_incrementing_twice_THEN_the_second_call_blocks` (edge case from spec.md)

**Gate**: `php artisan test --filter=CheckAndIncrementQuotaTest`
**Commit**: `feat(api): add CheckAndIncrementQuota use case`

---

### T16: `ResetPeriodUsage` use case (scheduled) [P]

**What**: MON-11, MON-12 — resets every subscription's usage count to 0 at each calendar-month boundary.
**Where**: `api/src/Domain/Billing/UseCase/ResetPeriodUsage.php`
**Depends on**: T9
**Reuses**: `src/Domain/Notification/UseCase/DetectRegionalPublishes.php` (scheduled-use-case shape reference — plain `execute()`, no params, wired via `Schedule::call` in T23)
**Requirement**: MON-11, MON-12

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(): void` iterates `SubscriptionRepository::all()`, resets `publishes_used_this_period = 0`, advances `current_period_start`/`current_period_end` to the new calendar month, saves each
- [ ] Runs independent of each subscription's individual `current_period_start` (MON-26's independence rule applies here too, even though MON-26 itself is P2)
- [ ] `php artisan test --filter=ResetPeriodUsageTest` passes (2 tests)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/ResetPeriodUsageTest.php`
- `test_GIVEN_subscriptions_at_full_usage_WHEN_resetting_THEN_every_usage_count_becomes_zero` (MON-11)
- `test_GIVEN_subscriptions_with_different_signup_dates_WHEN_resetting_THEN_all_are_reset_regardless_of_signup_date`

**Gate**: `php artisan test --filter=ResetPeriodUsageTest`
**Commit**: `feat(api): add ResetPeriodUsage use case`

---

### T17: `GetOrganizerUsage` use case [P]

**What**: MON-17, MON-18 — plan/usage summary for the organizer's own view.
**Where**: `api/src/Domain/Billing/UseCase/GetOrganizerUsage.php`
**Depends on**: T9
**Requirement**: MON-17, MON-18

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `execute(SubscribableType, int $subscribableId): UsageSummary` (small readonly DTO: plan name, monthly price, quota, `publishesUsedThisPeriod`, `isAtLimit`)
- [ ] `isAtLimit` true iff `publishes_used_this_period >= publish_quota` and quota isn't null
- [ ] `php artisan test --filter=GetOrganizerUsageTest` passes (2 tests)

**Tests**: unit — `api/tests/Unit/Domain/Billing/UseCase/GetOrganizerUsageTest.php`
- `test_GIVEN_3_of_5_publishes_used_WHEN_getting_usage_THEN_it_reports_3_of_5_and_not_at_limit` (MON-17)
- `test_GIVEN_5_of_5_publishes_used_WHEN_getting_usage_THEN_it_flags_at_limit` (MON-18)

**Gate**: `php artisan test --filter=GetOrganizerUsageTest`
**Commit**: `feat(api): add GetOrganizerUsage use case`

---

### T18: Extend `DecideAccountApproval` to create a subscription on approval

**What**: MON-04, MON-05 — on `ApprovalOutcome::Approved` for a Venue/Promoter, call `CreateSubscriptionOnApproval` after the account's `approval_status` is saved.
**Where**: `api/src/Domain/Approval/UseCase/DecideAccountApproval.php` (modify — targeted diff, not a rewrite)
**Depends on**: T14
**Reuses**: existing file (read above) — inject `CreateSubscriptionOnApproval` as a new constructor dependency; call it only in the `ApprovalOutcome::Approved` branch, only for Venue/Promoter (never Event — already guarded by the existing early throw at line 33–35)
**Requirement**: MON-04, MON-05

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `CreateSubscriptionOnApproval` injected via constructor
- [ ] Called with the correct `SubscribableType` (`Venue`/`Promoter`, mapped from `$accountType`) only when `$outcome === ApprovalOutcome::Approved`
- [ ] Not called for `Rejected`/`Suspended`/`SuspensionLifted` outcomes
- [ ] If `CreateSubscriptionOnApproval` throws (no default plan configured), the whole approval fails — the account's `approval_status` save and the exception must be atomic (wrap in a DB transaction if the existing method isn't already one)
- [ ] `php artisan test --filter=DecideAccountApprovalTest` passes, existing test count + 3 new ones, no regressions

**Tests**: unit — extend `api/tests/Unit/Domain/Approval/UseCase/DecideAccountApprovalTest.php`
- `test_GIVEN_a_venue_is_approved_WHEN_deciding_THEN_a_subscription_is_created_on_the_default_free_plan` (MON-04)
- `test_GIVEN_a_promoter_is_approved_WHEN_deciding_THEN_a_subscription_is_created_on_the_default_free_plan` (MON-04)
- `test_GIVEN_no_default_free_plan_configured_WHEN_approving_an_account_THEN_the_approval_is_blocked_and_no_status_change_persists` (MON-05)

**Gate**: `php artisan test --filter=DecideAccountApprovalTest`
**Commit**: `feat(api): create a default-plan subscription when an account is approved`

---

### T19: Extend `SubmitEventForReview` to enforce the publish quota

**What**: MON-07–MON-10 — before the `Draft → PendingReview` transition, call `CheckAndIncrementQuota` for the event's organizer. Approval/rejection paths (`DecideEventApproval`) are explicitly NOT touched (MON-09).
**Where**: `api/src/Domain/Event/UseCase/SubmitEventForReview.php` (modify — targeted diff)
**Depends on**: T15
**Reuses**: existing file (read above) — inject `CheckAndIncrementQuota`, call it right after the `canPublish()` check and before `$event->transitionTo(...)`
**Requirement**: MON-07, MON-08, MON-09, MON-10

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `CheckAndIncrementQuota` injected via constructor
- [ ] Called with the organizer's `SubscribableType`/id derived from `$organizer` (Venue→`SubscribableType::Venue`, Promoter→`SubscribableType::Promoter`)
- [ ] If it throws, `$event` is NOT transitioned or saved (quota check happens strictly before the transition)
- [ ] `src/Domain/Approval/UseCase/DecideEventApproval.php` is untouched — grep confirms no `CheckAndIncrementQuota` reference there (MON-09)
- [ ] `php artisan test --filter=SubmitEventForReviewTest` passes, existing test count + 3 new ones, no regressions

**Tests**: unit — extend `api/tests/Unit/Domain/Event/UseCase/SubmitEventForReviewTest.php`
- `test_GIVEN_the_organizer_is_under_quota_WHEN_submitting_THEN_the_event_transitions_and_the_quota_count_increments` (MON-07)
- `test_GIVEN_the_organizer_is_at_quota_WHEN_submitting_THEN_it_is_blocked_and_the_event_stays_in_draft` (MON-08)
- `test_GIVEN_the_organizer_is_on_an_unlimited_quota_plan_WHEN_submitting_THEN_it_never_blocks` (MON-10)

**Gate**: `php artisan test --filter=SubmitEventForReviewTest`
**Commit**: `feat(api): enforce publish quota on event submission`

---

### T20: Public `GET /api/v1/plans` endpoint

**What**: MON-01–MON-03 — public, unauthenticated plans list for the landing page.
**Where**: `api/src/Http/Controllers/Api/V1/PlanController.php` (new), `api/routes/api_v1.php` (modify — add one route)
**Depends on**: T10
**Reuses**: `src/Http/Controllers/Api/V1/EventController.php::index` (public-list controller shape reference)
**Requirement**: MON-01–MON-03

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `index(): JsonResponse` calls `ListActivePlans::execute()`, returns `{data: [...]}` with each plan's name/monthly_price/annual_price/publish_quota
- [ ] Route added inside the existing `throttle:qor-public-api` group in `api_v1.php`
- [ ] `php artisan test --filter=PlanControllerTest` passes (3 tests)

**Tests**: integration (Feature, `RefreshDatabase`) — `api/tests/Feature/Http/Controllers/Api/V1/PlanControllerTest.php`
- `test_GIVEN_active_plans_exist_WHEN_listing_publicly_THEN_they_are_returned_with_name_price_and_quota` (MON-01)
- `test_GIVEN_no_authentication_WHEN_listing_plans_THEN_it_succeeds` (MON-01 — public endpoint)
- `test_GIVEN_a_deactivated_plan_WHEN_listing_publicly_THEN_it_is_not_included` (MON-03)

**Gate**: `php artisan test --filter=PlanControllerTest`
**Commit**: `feat(api): add public plans list endpoint`

---

### T21: Super Admin Plan CRUD endpoints

**What**: MON-13–MON-16 — create/edit/deactivate plans, Super-Admin-only.
**Where**: `api/src/Http/Controllers/Api/AdminV1/PlanController.php` (new), `api/src/Http/Requests/Api/AdminV1/CreatePlanRequest.php`, `.../UpdatePlanRequest.php` (new), `api/routes/api_admin_v1.php` (modify)
**Depends on**: T11, T12, T13
**Reuses**: `routes/api_admin_v1.php`'s existing `approvals` prefix group pattern — reuse the already-established `['auth:admin', 'guard.admin', 'guard.super-admin']` middleware stack (no new Policy class needed, per the codebase's existing convention for Super-Admin-only routes)
**Requirement**: MON-13, MON-14, MON-15, MON-16

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `index(): JsonResponse` (all plans, not just active — Super Admin needs to see deactivated ones too), `store(CreatePlanRequest): JsonResponse`, `update(UpdatePlanRequest, id): JsonResponse`, `deactivate(id): JsonResponse`
- [ ] `CreatePlanRequest`/`UpdatePlanRequest` validate name/monthly_price/publish_quota required, non-negative numeric ranges, pt-BR messages (MON-16)
- [ ] Routes added under `Route::prefix('plans')->middleware(['auth:admin', 'guard.admin', 'guard.super-admin'])` in `api_admin_v1.php`
- [ ] `php artisan test --filter=Admin.*PlanControllerTest` passes (7 tests)

**Tests**: integration (Feature, `RefreshDatabase`) — `api/tests/Feature/Http/Controllers/Api/AdminV1/PlanControllerTest.php`
- `test_GIVEN_valid_plan_data_WHEN_a_super_admin_creates_a_plan_THEN_it_is_created_and_visible_publicly` (MON-13)
- `test_GIVEN_a_missing_required_field_WHEN_creating_a_plan_THEN_it_returns_a_field_specific_error` (MON-16)
- `test_GIVEN_an_existing_plan_WHEN_a_super_admin_updates_its_quota_THEN_the_change_applies_going_forward` (MON-14)
- `test_GIVEN_an_existing_plan_WHEN_a_super_admin_deactivates_it_THEN_it_disappears_from_the_public_list` (MON-15)
- `test_GIVEN_a_non_super_admin_admin_user_WHEN_attempting_plan_crud_THEN_it_is_rejected_with_403` (guard-isolation, mirrors ADMIN-30 precedent)
- `test_GIVEN_a_fan_token_WHEN_attempting_plan_crud_THEN_it_is_rejected`
- `test_GIVEN_an_unauthenticated_request_WHEN_attempting_plan_crud_THEN_it_is_rejected`

**Gate**: `php artisan test --filter=Admin.*PlanControllerTest`
**Commit**: `feat(api): add Super Admin plan CRUD endpoints`

---

### T22: Organizer usage view endpoint

**What**: MON-17, MON-18 — an organizer's own plan/usage view.
**Where**: `api/src/Http/Controllers/Api/AdminV1/SubscriptionController.php` (new), `api/routes/api_admin_v1.php` (modify)
**Depends on**: T17
**Reuses**: `src/Http/Controllers/Api/AdminV1/DashboardController.php` (organizer-scoped-view controller shape reference — resolves the calling admin's own Venue/Promoter, same pattern)
**Requirement**: MON-17, MON-18

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `show(): JsonResponse` resolves the authenticated admin's own Venue or Promoter, calls `GetOrganizerUsage::execute(...)`, returns plan name/price/quota/used/isAtLimit
- [ ] Route `GET /subscription` added inside the existing `['auth:admin', 'guard.admin']` group (any organizer, not Super-Admin-only)
- [ ] `php artisan test --filter=SubscriptionControllerTest` passes (2 tests)

**Tests**: integration (Feature, `RefreshDatabase`) — `api/tests/Feature/Http/Controllers/Api/AdminV1/SubscriptionControllerTest.php`
- `test_GIVEN_an_organizer_with_3_of_5_used_WHEN_viewing_their_subscription_THEN_the_response_shows_3_of_5` (MON-17)
- `test_GIVEN_an_organizer_at_their_limit_WHEN_viewing_their_subscription_THEN_the_response_flags_at_limit` (MON-18)

**Gate**: `php artisan test --filter=SubscriptionControllerTest`
**Commit**: `feat(api): add organizer plan/usage view endpoint`

---

### T23: Schedule `ResetPeriodUsage`

**What**: MON-11 — wire the reset job to run at each calendar-month boundary.
**Where**: `api/routes/console.php` (modify — add one `Schedule::call(...)`)
**Depends on**: T16
**Reuses**: `routes/console.php`'s existing `Schedule::call(fn () => app(...)->execute())` pattern for the Phase 5a detectors
**Requirement**: MON-11

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `Schedule::call(fn () => app(ResetPeriodUsage::class)->execute())->monthlyOn(1, '00:00');` added
- [ ] `php artisan schedule:list` shows the new entry

**Tests**: none (scheduler wiring — covered by T16's use-case unit tests)
**Gate**: `php artisan schedule:list`
**Commit**: `feat(api): schedule the monthly quota-usage reset`

---

### T24: Seed a default free plan

**What**: MON-04, MON-06 — local-dev seeder creates the default free plan row, per ARCHITECTURE.md §8.7/§14.2 (the `5` appears only here, read from config).
**Where**: `api/database/seeders/PlanSeeder.php` (new), `api/database/seeders/DatabaseSeeder.php` (modify — add one `$this->call(...)`)
**Depends on**: T7, T1
**Reuses**: `database/seeders/GenreSeeder.php` (simple lookup-row seeder shape reference)
**Requirement**: MON-04, MON-06

**Tools**: Skill: `laravel-specialist`

**Done when**:
- [ ] `PlanSeeder` creates one `Plan` row: name "Gratuito", `monthly_price = 0`, `publish_quota =
  config('qor.billing.default_free_quota')`, `is_active = true`, `is_default_free = true`
- [ ] Called from `DatabaseSeeder::run()` before `VenueSeeder`/`PromoterSeeder` (subscriptions need a
  default plan to attach to if seeded venues/promoters are pre-approved)
- [ ] `php artisan db:seed` runs clean

**Tests**: none (seeder-only, matches precedent — no other seeder has a dedicated test)
**Gate**: `php artisan db:seed` (test DB)
**Commit**: `feat(api): seed the default free plan`

---

### T25: Full gate + requirement traceability

**What**: Run the full CI-equivalent gate and close out MON-01–MON-18's traceability rows.
**Where**: `.specs/features/monetization/spec.md` (Requirement Traceability table)
**Depends on**: T18, T19, T20, T21, T22, T23, T24
**Requirement**: MON-01–MON-18

**Tools**: Skill: NONE

**Done when**:
- [ ] `vendor/bin/phpstan analyse --memory-limit=512M --error-format=github` clean
- [ ] `php artisan test --coverage --min=80` passes
- [ ] `spec.md`'s MON-01–MON-18 rows flipped from "In Design" to "Done", mapped to their tasks; coverage summary line updated (26 total, 18 now mapped/Done, 8 unmapped — MON-19–26 remain In Design, deferred to a future P2 pass)
- [ ] `.specs/project/ROADMAP.md`'s Monetization line updated once T27 (review) closes — not here

**Tests**: none (gate/docs task)
**Gate**: full — `php artisan test --coverage --min=80` (matches `api/.github/workflows/api-ci.yml`)
**Commit**: `docs(monetization): close MON-01-18 traceability after P1 implementation`

---

### T26: Extend Postman collection

**What**: ARCHITECTURE.md §8.9 — document the new endpoints.
**Where**: `api`'s Postman collection file(s) (same location as the venue-promoter-admin collection updates)
**Depends on**: T25
**Requirement**: N/A (deliverable, not a spec requirement)

**Tools**: Skill: NONE

**Done when**:
- [ ] `GET /api/v1/plans`, `GET/POST/PATCH /api/admin/v1/plans`, `POST /api/admin/v1/plans/{id}/deactivate`, `GET /api/admin/v1/subscription` all present with sample requests/responses matching the seeded free plan

**Tests**: none
**Gate**: none (docs)
**Commit**: `docs(monetization): extend Postman collection with plan and subscription endpoints`

---

### T27: Review-before-merge — `review-laravel-api`

**What**: After the PR for this milestone slice is opened, run `review-laravel-api` per CLAUDE.md's Review-before-merge rule. Apply valid fixes silently, note declined/out-of-scope findings in the PR thread.
**Where**: PR for `feat/api-monetization` (GitHub); any files the review flags
**Depends on**: T25 (PR must be open)
**Requirement**: N/A (process gate)

**Tools**: Skill: NONE (invoke `review-laravel-api` agent directly)

**Done when**:
- [ ] `review-laravel-api` run against the open PR
- [ ] Findings posted as a PR comment
- [ ] Every finding triaged: fixed (follow-up commit) or declined/out-of-scope, noted in the PR thread
- [ ] If fixes applied: `vendor/bin/phpstan analyse --memory-limit=512M` and `php artisan test --coverage --min=80` re-run and passing
- [ ] PR updated/pushed with final state

**Tests**: re-run affected suites if fixes are applied
**Gate**: full — `php artisan test --coverage --min=80`
**Commit**: `fix(api): address review-laravel-api findings on monetization PR` (only if fixes are needed)

---

## Parallel Execution Map

```
Phase 1 (Parallel): T1, T2, T3, T4
Phase 2 (Parallel, after T1/T2): T5, T6
Phase 3: T7 [P] (after T3, T5), T8 [P] (after T4, T6) → T9
Phase 4 (Parallel, after T9): T10, T11, T12, T13, T14, T15, T16, T17
Phase 5: T18 (after T14), T19 (after T15)
Phase 6: T20 (after T10), T21 (after T11/T12/T13), T22 (after T17)
Phase 7: T23 (after T16), T24 (after T7, T1)
Phase 8 (Sequential): T25 → T26 → (open PR) → T27
```

**Parallelism constraint check**: T1–T4 touch disjoint files (config, enums, two separate migration
files). T5/T6 touch disjoint entity files. T7/T8 touch disjoint repository/model/adapter files. T10–T17
each touch one new use-case file with no shared mutable state — all `[P]`-safe. T18/T19 touch different
existing files (`DecideAccountApproval.php` vs `SubmitEventForReview.php`) and could run in parallel
despite the diagram showing them sequential per-dependency-chain; listed sequentially only because
each depends on a different Phase-4 task finishing first, not because of a file conflict.

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|------|------------------------|----------------|--------|
| T1–T4 | None | None | ✅ Match |
| T5 | T1, T2 (namespace co-location, not functional) | T1, T2 → T5 | ✅ Match |
| T6 | T2 | T1, T2 → T6 | ✅ Match (T1 listed alongside for grouping only) |
| T7 | T3, T5 | T3, T5 → T7 | ✅ Match |
| T8 | T4, T6 | T4, T6 → T8 | ✅ Match |
| T9 | T7, T8 | T7, T8 → T9 | ✅ Match |
| T10–T17 | T9 | T9 → T10..T17 | ✅ Match |
| T18 | T14 | T14 → T18 | ✅ Match |
| T19 | T15 | T15 → T19 | ✅ Match |
| T20 | T10 | T10 → T20 | ✅ Match |
| T21 | T11, T12, T13 | T11, T12, T13 → T21 | ✅ Match |
| T22 | T17 | T17 → T22 | ✅ Match |
| T23 | T16 | T16 → T23 | ✅ Match |
| T24 | T7, T1 | T7 → T24 | ⚠️ T1 dependency (config key) implicit — both are prerequisites, diagram shows only T7 for brevity |
| T25 | T18, T19, T20, T21, T22, T23, T24 | all → T25 | ✅ Match |
| T26 | T25 | T25 → T26 | ✅ Match |
| T27 | T25 (PR open) | T26 → (PR) → T27 | ✅ Match |

---

## Test Co-location Validation

Convention inferred from the existing codebase (unit for domain use cases/entities, Feature/integration
for controllers and Eloquent adapters — same convention the admin-login tasks.md validated against).

| Task | Code Layer Created/Modified | Convention Requires | Task Says | Status |
|------|------------------------------|----------------------|-----------|--------|
| T1–T4 | Config, enums, migrations | none | none | ✅ OK |
| T5 | Domain entity (plain data) | none (matches `Plan`-shape precedent) | none | ✅ OK |
| T6 | Domain entity (plain data) | none | none | ✅ OK |
| T7, T8 | Eloquent adapters | integration | integration | ✅ OK |
| T9 | DI wiring | none | none | ✅ OK |
| T10–T17 | Domain use cases | unit | unit | ✅ OK |
| T18, T19 | Existing domain use cases (extended) | unit (extend existing suite) | unit | ✅ OK |
| T20, T21, T22 | Http controllers + routes | integration (Feature) | integration | ✅ OK |
| T23 | Scheduler wiring | none | none | ✅ OK |
| T24 | Seeder | none | none | ✅ OK |
| T25 | Gate/docs only | none | none | ✅ OK |
| T26 | Docs only | none | none | ✅ OK |
| T27 | Process gate | re-run existing suites | re-run existing suites | ✅ OK |

---

## Tips (from skill template — kept for Execute-phase reference)

- **[P] = Parallel OK** — Phase 1, Phase 2, and Phase 4's use cases can each run via concurrent sub-agents
- **Reuses = Token saver** — every task cites its existing-code mirror (Venue/Event/Approval/Notification precedents)
- **One commit per task** — T1–T24 each get one Conventional Commit; T25/T26 are docs commits; T27 gets zero or more fix commits
- **Requirement ID = Traceable** — every task maps to MON-01–MON-18

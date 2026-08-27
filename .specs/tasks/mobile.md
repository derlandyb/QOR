# Mobile Tasks — `mobile` (KMP + Compose/SwiftUI)

**Submodule**: `qor-mobile` (git remote name) — checked out locally as `mobile/`
**Design refs**: `.specs/features/event-discovery/design.md`, `.specs/features/auth-fan-profile/design.md`
**Architecture ref**: `.specs/project/ARCHITECTURE.md`; design system: `design-system.md` (NIGHTLIFE-GV)
**Status**: Draft
**Milestone**: MVP Core only (Event Discovery P1 + Auth & Fan Profile P1/AUTH-25). Venue/Promoter Admin is admin-panel-only, not mobile.
**Not in mobile scope**: map view (not requested by `event-discovery` spec/design — see `api.md`'s closing note), social/friends parts of profile (Favorites & Social milestone), notification preference UI (P2, `auth-fan-profile` — Pending, not designed yet).

**Repo split rule (ARCHITECTURE §8.10)**: Shared/Android/iOS are separate commit boundaries — never mixed in one commit. This file is organized the same way for that reason, not just for readability.

**Test coverage**: no `TESTING.md` yet (greenfield). Test-type-per-layer: shared domain use cases → **unit** (`kotlin.test`/JUnit, run on the JVM target), Compose UI components/screens → **unit** (Compose UI test / Robolectric for logic, no live-device requirement for gating), SwiftUI equivalents → **unit** (XCTest). Design-token/constant files → **none** (compile-check only).

**Tools (all tasks, unless overridden, confirmed with user)**: MCP `context7` (KMP/Compose/SwiftUI API lookups), `stitch` (`mcp__stitch__get_screen`, called for every UI task referencing a Stitch screen ID below, to pull the actual screen HTML for structural reference before implementing), `github` (PR creation, split per platform commit boundary per §8.10) / Skill `NONE`.

---

## Stitch screen reference (project `6008587636717635180`)

| Screen (pt-BR title) | Stitch screen ID | Feature |
|---|---|---|
| Entrar no Qual o Rock? - Com Recuperação | `cfa5690fed3d487897d65de249ad7f1d` | auth-fan-profile (login) |
| Criar conta - Confirmação de Senha | `d4965c8bc3a740158366d6a9a45ed459` | auth-fan-profile (signup) |
| Verificação de E-mail - Código | `31a89c6e38cd4136998d650e9d778f73` | auth-fan-profile |
| Recuperar Senha | `32a562fe876e4d0cb2eb87c2140de64e` | auth-fan-profile |
| Feedback de Sucesso - Recuperação de Senha | `bfdd2ec9b4c944c0a3f7c26793fb02c3` | auth-fan-profile |
| Bem-vindo - Registro Concluído | `02effbddb07e427888e53a7501c6b82c` | auth-fan-profile |
| Início - O que tá rolando? | `32c8c87d76994eaf9f42cd320c2759e5` | event-discovery (home feed) |
| Explorar Eventos | `642def01ae144e1f8a1896018febf379` | event-discovery |
| Detalhes do Evento | `391ebe25bee544b89dc309283b2b9008` | event-discovery |
| Meu Perfil - Foco Social | `ee5dea95cc384522b7705c2eb44ac552` | auth-fan-profile (basic-info fields only) |

**Important**: use these screens for layout/flow structure only. Stitch's own "Vix Rock Discovery" design theme (teal/aqua, Geist font) is **not** used — every screen is re-skinned with NIGHTLIFE-GV tokens (`design-system.md`) as ported into KMP constants in T3 below.

---

## Execution Plan

### Shared (sequential foundation, then parallel-safe use cases)

```
S1 → S2 → S3 → S4 → S5
S5 ──┬→ S6 ─┐
     ├→ S7 ─┼→ S9
     └→ S8 ─┘
S6,S7,S8 also → S10, S11 [P]
```

### Android (after Shared S5 for tokens, after S9–S11 for domain hookup)

```
S3 → A1 → A2 → A3 [P] A4 [P] A5 [P] A6 [P]
(A2's component library) A2 → A7,A8,A9,A10,A11,A12,A13 [P] (screens, each depends on its matching Shared use case)
A7 → A14 (nav wiring, sequential after all screens exist)
```

### iOS (mirrors Android exactly, independent commits)

```
S3 → I1 → I2 → I3 [P] I4 [P] I5 [P] I6 [P]
I2 → I7,I8,I9,I10,I11,I12,I13 [P]
I7 → I14
```

---

## Shared Module Tasks

#### S1: Scaffold `mobile` KMP repo
**What**: Kotlin Multiplatform project with `shared`, `androidApp`, `iosApp` modules per ARCHITECTURE §1; confirm local toolchain (Gradle + Xcode, no Docker per §8.1 — mobile is the one non-Dockerized repo).
**Where**: `mobile/settings.gradle.kts`, `mobile/shared/`, `mobile/androidApp/`, `mobile/iosApp/`
**Depends on**: None
**Reuses**: n/a
**Requirement**: ARCHITECTURE §1, §8.1
**Done when**:
- [ ] `./gradlew build` succeeds for `shared` + `androidApp`; `xcodebuild -scheme iosApp build` succeeds
- [ ] README documents the non-Docker local setup steps
**Tests**: none
**Gate**: build

#### S2: CI workflow — split Android/iOS jobs
**What**: One GitHub Actions workflow with two jobs: Android (Linux runner, `./gradlew test detekt`) and iOS (`macos-*` runner, `xcodebuild test` + SwiftLint), per ARCHITECTURE §8.2.
**Where**: `.github/workflows/mobile-ci.yml` (in `qor-mobile` repo)
**Depends on**: S1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §8.2, §8.4
**Done when**:
- [ ] Both jobs run independently and are both required checks on PRs to `mobile`'s `main`
**Tests**: none
**Gate**: build

#### S3: Design-token layer (NIGHTLIFE-GV → KMP constants)
**What**: Port `design-system.md` §2 tokens — colors (hex + oklch), typography scale (Space Grotesk/Inter — confirm Google Fonts availability on Android/iOS or bundle as app fonts), spacing/radii scale, and §3 motion durations/easings (`--duration-fast/base/slow/stagger`, `--ease-beat`/`--ease-smooth` as `cubic-bezier` equivalents) — as plain Kotlin constants in `shared`, consumable by both platform UIs.
**Where**: `mobile/shared/src/commonMain/kotlin/design/NightlifeGvTokens.kt`
**Depends on**: S1
**Reuses**: `design-system.md` §2–3 verbatim values — this is the one part of the design system already platform-neutral (per prior research pass)
**Requirement**: user request — "design-system components for mobile", `design-system.md` §2–3
**Done when**:
- [ ] Every color/type/spacing/radius/motion token from `design-system.md` §2–3 has a named Kotlin constant, no magic hex/px/ms literals duplicated in Android or iOS code later
- [ ] Space Grotesk/Inter bundled as app font resources (both platforms) since Google Fonts CDN isn't guaranteed offline on mobile
**Tests**: none
**Gate**: build

#### S4: Domain layer scaffold — Clean Architecture, zero framework deps
**What**: `commonMain` domain package structure mirroring `api`'s `src/Domain/**` shape (Event, User packages), confirming no Android/iOS/framework imports leak into `commonMain/domain`.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/`
**Depends on**: S1
**Reuses**: `api/src/Domain/**` shape as the cross-platform naming reference (independent implementation, same concepts)
**Requirement**: ARCHITECTURE §8.5
**Done when**:
- [ ] Static-analysis rule (detekt) blocking `android.*`/platform imports inside `domain/` package, wired into S2's CI
**Tests**: none
**Gate**: build

#### S5: Enums mirrored from `api` as Kotlin `enum class`
**What**: `EventStatus`, `ApprovalStatus` (read-only relevance to mobile — needed for rendering only), `City`, `ConsentType` — Kotlin `enum class` mirrors of `api`'s backed PHP enums, never raw string comparisons client-side.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/enum/`
**Depends on**: S4
**Reuses**: `api.md` T4's enum definitions (exact case names/values must match the API contract)
**Requirement**: ARCHITECTURE §14.1
**Done when**:
- [ ] Each enum's cases match `api`'s backed enum values exactly (cross-file contract — verified against `api.md` T4)
- [ ] Unit test: JSON deserialization of each raw API value resolves to the correct Kotlin case, unknown value fails loudly (not silently defaults)
**Tests**: unit
**Gate**: quick

#### S6: `Event` domain model + `EventRepository` interface + networking client
**What**: `Event` data class mirroring `api`'s entity shape; `EventRepository` interface (`findUpcoming`, `findById`); Ktor (or equivalent KMP HTTP client) implementation calling `GET /api/v1/events` / `/api/v1/events/{id}` (contract from `api.md` T25).
**Where**: `mobile/shared/src/commonMain/kotlin/domain/event/`, `mobile/shared/src/commonMain/kotlin/data/EventRepositoryImpl.kt`
**Depends on**: S5
**Reuses**: `api.md` T25's exact endpoint contract (query params, response envelope)
**Requirement**: `event-discovery/design.md`
**Done when**:
- [ ] Unit test (mocked HTTP engine): request built with correct query params for city/genre/cursor filters; response mapped to `Event` correctly; cancelled/encerrado state payload mapped to a distinct UI state, not treated as a normal event
**Tests**: unit
**Gate**: quick

#### S7: `ListUpcomingEvents` / `GetEventDetails` shared use cases
**What**: KMP-shared use cases wrapping `EventRepository`, identical contract shape to `api.md` T23/T24 (`execute(city?, genre?, cursor?)`, `execute(eventId)`).
**Where**: `mobile/shared/src/commonMain/kotlin/domain/event/usecase/`
**Depends on**: S6
**Reuses**: `EventRepository` (S6)
**Requirement**: DISC-01–DISC-18 (client-side consumption)
**Done when**: unit tests mirroring `api.md` T23/T24's scenarios at the client-mapping level (filter combination, empty results, cancelled/encerrado handling)
**Tests**: unit
**Gate**: quick

#### S8: `User` domain model + `UserRepository` interface + auth networking client
**What**: `User` data class; `UserRepository` interface (`login`, `register`, `resetPassword`, `getProfile`, `updateProfile`); Ktor client calling `api.md` T31/T32's endpoints; secure token storage wiring (iOS Keychain / Android EncryptedSharedPreferences per ARCHITECTURE §2 — bearer token, never plain app storage).
**Where**: `mobile/shared/src/commonMain/kotlin/domain/user/`, `data/UserRepositoryImpl.kt`, platform-specific `expect`/`actual` secure-storage implementations
**Depends on**: S5
**Reuses**: `api.md` T31/T32's exact endpoint contracts
**Requirement**: `auth-fan-profile/design.md`, ARCHITECTURE §2
**Done when**:
- [ ] Unit test (mocked HTTP engine): each auth/profile call builds correctly and maps responses/errors to domain results
- [ ] `expect`/`actual` secure-storage functions exist for both Android and iOS, token never touches unencrypted storage
**Tests**: unit
**Gate**: quick

#### S9: Shared auth use cases (`RegisterFan`, `AuthenticateFan`, `ResetPassword`, `UpdateProfile`, `ExerciseDataRight` — client wrappers)
**What**: Thin KMP-shared wrappers around `UserRepository` matching `api.md`'s use-case names/contracts, so both platform UIs call identical shared logic rather than duplicating auth flow orchestration.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/user/usecase/`
**Depends on**: S8
**Reuses**: `UserRepository` (S8)
**Requirement**: AUTH-01–AUTH-19, AUTH-25 (client-side)
**Done when**: unit tests mirroring `api.md`'s T26–T30 scenarios at the client-mapping level (error message pass-through, session persistence trigger)
**Tests**: unit
**Gate**: quick

#### S10: Local session/state store [P]
**What**: Shared observable session state (logged-in user, auth token presence) consumable by both Compose and SwiftUI via KMP's expected state-flow bridging.
**Where**: `mobile/shared/src/commonMain/kotlin/data/SessionStore.kt`
**Depends on**: S8
**Reuses**: `UserRepository` (S8)
**Requirement**: AUTH-12 (session persistence across app restarts)
**Tests**: unit
**Gate**: quick

#### S11: Polling coordinator for live event-list updates [P]
**What**: Shared polling loop (interval from `qor.polling.event_list_interval_seconds`, mirrored client-side per `event-discovery/design.md`'s Tech Decision) plus pull-to-refresh trigger, both platforms subscribe to the same shared flow.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/event/PollingCoordinator.kt`
**Depends on**: S7
**Reuses**: `ListUpcomingEvents` (S7)
**Requirement**: DISC-04
**Tests**: unit
**Gate**: quick

---

## Android Tasks (Jetpack Compose)

#### A1: Android app module wiring
**What**: Wire `androidApp` to consume `shared`, set up Compose, navigation-compose, DI (Koin or manual — no framework choice made elsewhere, default to Koin as the common KMP-friendly choice, flagged for confirmation).
**Where**: `mobile/androidApp/src/main/`
**Depends on**: S1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §1
**Tests**: none
**Gate**: build

#### A2: Compose design-system component library
**What**: Build the NIGHTLIFE-GV component set in Compose, re-deriving `design-system.md` §3/§4's CSS/Tailwind animation specs into Compose equivalents:
- **EventCard** (§4.1): image holder w/ `animateFloatAsState` hover-equivalent (press) scale to 1.03 + `AnimatedVisibility`/offset for the -4dp rise, pink-tinted elevation shadow; floating date badge; floating genre tag; CTA row.
- **CityFilterBar** (§4.2): pill row, inactive (15% alpha tint) vs. active (solid + `animateFloatAsState` scale to 1.05) states, `Modifier.semantics` for the `aria-pressed` equivalent.
- **GenreTagSet** (§4.3): 5-genre color mapping table from the spec.
- **Gradient CTA buttons** (§4.4): "Ver no Mapa" (blue outline→solid on press) and "Ver Instagram" (pink→purple gradient with an animated `Brush` offset mimicking the `background-position` shift).
- **Entrance stagger**: `LazyColumn`/`LazyVerticalGrid` item entrance using `animateItemPlacement` + per-index `animationSpec` delay mimicking `card-enter`'s 60ms stagger.
- **Live-pulse badge**: `rememberInfiniteTransition` 1.8s ease-in-out pulse, pink accent, for "Ao vivo".
**Where**: `mobile/androidApp/src/main/kotlin/ui/components/`
**Depends on**: S3
**Reuses**: `NightlifeGvTokens` (S3), `design-system.md` §4 blueprints as the structural/behavioral spec (re-derived, not copy-pasted — Compose isn't HTML)
**Requirement**: user request — mobile design-system components + animations
**Done when**:
- [ ] Each component listed above exists, visually matches its `design-system.md` blueprint's structure and every documented animation (hover/press scale+rise+glow, gradient shift, entrance stagger, live pulse, filter toggle cross-fade)
- [ ] Focus states are instant (no animation), matching §3's explicit a11y rule
- [ ] Compose UI tests: each component renders with required props; animated state transitions reach their target values
**Tests**: unit
**Gate**: quick

#### A3: `BottomNav` component [P]
**What**: Fixed bottom navigation, items relevant to MVP Core scope (Início, Explorar, Favoritos*, Perfil — *Favoritos tab renders but the favoriting action itself is out of scope this milestone; tab exists for nav-shell completeness per the Stitch reference, disabled/stub state acceptable), active-state icon + accent-color underline per `design-system.md`.
**Where**: `mobile/androidApp/src/main/kotlin/ui/components/BottomNav.kt`
**Depends on**: A2
**Reuses**: `NightlifeGvTokens` (S3)
**Requirement**: user request — screen structure per Stitch reference
**Tests**: unit
**Gate**: quick

#### A4: Empty-state / placeholder-image components [P]
**What**: Design-system-consistent empty state ("Nenhum evento encontrado") and placeholder cover image, per DISC edge cases.
**Where**: `mobile/androidApp/src/main/kotlin/ui/components/EmptyState.kt`, `PlaceholderImage.kt`
**Depends on**: A2
**Reuses**: `NightlifeGvTokens` (S3)
**Requirement**: event-discovery edge cases (empty list, missing image)
**Tests**: unit
**Gate**: quick

#### A5: Consent-capture UI component [P]
**What**: pt-BR privacy policy/terms display with a required, non-pre-checked acceptance checkbox — shared shape reused across signup screens.
**Where**: `mobile/androidApp/src/main/kotlin/ui/components/ConsentCapture.kt`
**Depends on**: A2
**Reuses**: `NightlifeGvTokens` (S3)
**Requirement**: AUTH-02, AUTH-03
**Tests**: unit
**Gate**: quick

#### A6: Form input components (email/password/text fields with error states) [P]
**What**: Text field variants with the design system's input styling and pt-BR inline validation error display, used by every auth screen.
**Where**: `mobile/androidApp/src/main/kotlin/ui/components/FormFields.kt`
**Depends on**: A2
**Reuses**: `NightlifeGvTokens` (S3)
**Requirement**: auth-fan-profile forms, client-side validation per its Error Handling Strategy
**Tests**: unit
**Gate**: quick

#### A7: `LoginScreen` [P]
**What**: Screen per Stitch `cfa5690fed3d487897d65de249ad7f1d` structure — email/password fields, "Entrar com Google" button, forgot-password link.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/LoginScreen.kt`
**Depends on**: A6, S9
**Reuses**: `AuthenticateFan` (S9), `FormFields`/`ConsentCapture` n/a here (A6)
**Requirement**: AUTH-06–AUTH-12; Stitch screen `cfa5690fed3d487897d65de249ad7f1d`
**Tests**: unit
**Gate**: quick

#### A8: `SignupScreen` (+ password confirmation step) [P]
**What**: Screen per Stitch `d4965c8bc3a740158366d6a9a45ed459`.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/SignupScreen.kt`
**Depends on**: A5, A6, S9
**Reuses**: `RegisterFan` (S9), `ConsentCapture` (A5), `FormFields` (A6)
**Requirement**: AUTH-01–AUTH-05; Stitch screen `d4965c8bc3a740158366d6a9a45ed459`
**Tests**: unit
**Gate**: quick

#### A9: `EmailVerificationScreen` [P]
**What**: Screen per Stitch `31a89c6e38cd4136998d650e9d778f73` — code entry + resend.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/EmailVerificationScreen.kt`
**Depends on**: A6, S9
**Requirement**: AUTH-10 (unverified block/resend); Stitch screen `31a89c6e38cd4136998d650e9d778f73`
**Tests**: unit
**Gate**: quick

#### A10: `PasswordRecoveryScreen` (+ success state) [P]
**What**: Screens per Stitch `32a562fe876e4d0cb2eb87c2140de64e` (request) and `bfdd2ec9b4c944c0a3f7c26793fb02c3` (success).
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/PasswordRecoveryScreen.kt`
**Depends on**: A6, S9
**Reuses**: `ResetPassword` (S9)
**Requirement**: AUTH-13–AUTH-16; Stitch screens `32a562fe876e4d0cb2eb87c2140de64e`, `bfdd2ec9b4c944c0a3f7c26793fb02c3`
**Tests**: unit
**Gate**: quick

#### A11: `HomeFeedScreen` [P]
**What**: Screen per Stitch `32c8c87d76994eaf9f42cd320c2759e5` — soonest-first event list, `CityFilterBar`, live-updating via S11's polling coordinator, entrance-stagger grid animation.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/HomeFeedScreen.kt`
**Depends on**: A2, A3, A4, S7, S11
**Reuses**: `EventCard`/`CityFilterBar` (A2), `EmptyState` (A4), `ListUpcomingEvents` (S7), `PollingCoordinator` (S11)
**Requirement**: DISC-01–DISC-06, DISC-14–DISC-18; Stitch screen `32c8c87d76994eaf9f42cd320c2759e5`
**Tests**: unit
**Gate**: quick

#### A12: `ExploreScreen` [P]
**What**: Screen per Stitch `642def01ae144e1f8a1896018febf379` — same list mechanics as A11 with genre filter emphasis, per DISC-15.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/ExploreScreen.kt`
**Depends on**: A2, A4, S7
**Reuses**: A11's list-rendering pattern
**Requirement**: DISC-14–DISC-18; Stitch screen `642def01ae144e1f8a1896018febf379`
**Tests**: unit
**Gate**: quick

#### A13: `EventDetailScreen` + basic `ProfileScreen` [P]
**What**: Detail screen per Stitch `391ebe25bee544b89dc309283b2b9008` — full fields, ticket-link button (paid only), embedded map, promoter contact list, native share; Profile screen per Stitch `ee5dea95cc384522b7705c2eb44ac552` scoped to basic-info fields only (username/email/phone/birthdate/picture — no social widgets).
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/EventDetailScreen.kt`, `ProfileScreen.kt`
**Depends on**: A2, A6, S7, S9
**Reuses**: `GetEventDetails` (S7), `UpdateProfile`/`ExerciseDataRight` (S9)
**Requirement**: DISC-07–DISC-13, AUTH-17–AUTH-19, AUTH-25; Stitch screens `391ebe25bee544b89dc309283b2b9008`, `ee5dea95cc384522b7705c2eb44ac552`
**Tests**: unit
**Gate**: quick

#### A14: Navigation graph wiring (sequential, after all screens exist)
**What**: `NavHost` wiring every screen above, deep-link handling for shared event URLs (cancelled/encerrado state banners per DISC edge cases), `BottomNav` integration.
**Where**: `mobile/androidApp/src/main/kotlin/ui/NavGraph.kt`
**Depends on**: A7, A8, A9, A10, A11, A12, A13, A3
**Reuses**: all screens above
**Requirement**: DISC-06 (card tap → details), deep-link edge cases
**Done when**: instrumented navigation test covering the full login→home→detail→back path and one deep-link case
**Tests**: unit
**Gate**: quick
**Commit**: `feat(mobile-android): wire navigation graph for MVP Core screens`

---

## iOS Tasks (SwiftUI)

*(Mirrors Android's component/screen list exactly — same requirement IDs, same Stitch screens, independent SwiftUI implementation and independent commits per ARCHITECTURE §8.10.)*

#### I1: iOS app module wiring
**What**: Wire `iosApp` to consume `shared` via the KMP framework, set up SwiftUI navigation (`NavigationStack`).
**Where**: `mobile/iosApp/iosApp/`
**Depends on**: S1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §1
**Tests**: none
**Gate**: build

#### I2: SwiftUI design-system component library
**What**: Same component set as A2, animations re-derived into SwiftUI: press-scale + rise via `.scaleEffect`/`.offset` inside `withAnimation(.spring(...))` approximating `--ease-beat`'s overshoot; gradient CTA via `LinearGradient` + animated `unitPoint`/`AnimatableModifier`; entrance stagger via per-index `.animation(.easeOut.delay(...))` in a `LazyVGrid`; live-pulse via `.repeatForever(autoreverses: true)` on shadow opacity.
**Where**: `mobile/iosApp/iosApp/UI/Components/`
**Depends on**: S3
**Reuses**: `NightlifeGvTokens` (S3, consumed via KMP interop), `design-system.md` §4 blueprints (structural/behavioral reference, re-derived not copy-pasted)
**Requirement**: user request — mobile design-system components + animations
**Done when**: same checklist shape as A2 — every component + every documented animation present, focus states instant
**Tests**: unit
**Gate**: quick

#### I3: `BottomNav` [P]
**Where**: `mobile/iosApp/iosApp/UI/Components/BottomNav.swift`
**Depends on**: I2
**Reuses**: `NightlifeGvTokens` (S3)
**Requirement**: same as A3
**Tests**: unit
**Gate**: quick

#### I4: Empty-state / placeholder-image components [P]
**Where**: `mobile/iosApp/iosApp/UI/Components/EmptyState.swift`, `PlaceholderImage.swift`
**Depends on**: I2
**Requirement**: same as A4
**Tests**: unit
**Gate**: quick

#### I5: Consent-capture UI component [P]
**Where**: `mobile/iosApp/iosApp/UI/Components/ConsentCapture.swift`
**Depends on**: I2
**Requirement**: same as A5
**Tests**: unit
**Gate**: quick

#### I6: Form input components [P]
**Where**: `mobile/iosApp/iosApp/UI/Components/FormFields.swift`
**Depends on**: I2
**Requirement**: same as A6
**Tests**: unit
**Gate**: quick

#### I7: `LoginView` [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/LoginView.swift`
**Depends on**: I6, S9
**Requirement**: same as A7; Stitch screen `cfa5690fed3d487897d65de249ad7f1d`
**Tests**: unit
**Gate**: quick

#### I8: `SignupView` [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/SignupView.swift`
**Depends on**: I5, I6, S9
**Requirement**: same as A8; Stitch screen `d4965c8bc3a740158366d6a9a45ed459`
**Tests**: unit
**Gate**: quick

#### I9: `EmailVerificationView` [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/EmailVerificationView.swift`
**Depends on**: I6, S9
**Requirement**: same as A9; Stitch screen `31a89c6e38cd4136998d650e9d778f73`
**Tests**: unit
**Gate**: quick

#### I10: `PasswordRecoveryView` (+ success state) [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/PasswordRecoveryView.swift`
**Depends on**: I6, S9
**Requirement**: same as A10; Stitch screens `32a562fe876e4d0cb2eb87c2140de64e`, `bfdd2ec9b4c944c0a3f7c26793fb02c3`
**Tests**: unit
**Gate**: quick

#### I11: `HomeFeedView` [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/HomeFeedView.swift`
**Depends on**: I2, I3, I4, S7, S11
**Requirement**: same as A11; Stitch screen `32c8c87d76994eaf9f42cd320c2759e5`
**Tests**: unit
**Gate**: quick

#### I12: `ExploreView` [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/ExploreView.swift`
**Depends on**: I2, I4, S7
**Requirement**: same as A12; Stitch screen `642def01ae144e1f8a1896018febf379`
**Tests**: unit
**Gate**: quick

#### I13: `EventDetailView` + basic `ProfileView` [P]
**Where**: `mobile/iosApp/iosApp/UI/Screens/EventDetailView.swift`, `ProfileView.swift`
**Depends on**: I2, I6, S7, S9
**Requirement**: same as A13; Stitch screens `391ebe25bee544b89dc309283b2b9008`, `ee5dea95cc384522b7705c2eb44ac552`
**Tests**: unit
**Gate**: quick

#### I14: Navigation wiring (sequential)
**What**: `NavigationStack` wiring, deep-link handling, `BottomNav` integration.
**Where**: `mobile/iosApp/iosApp/UI/AppNavigation.swift`
**Depends on**: I7, I8, I9, I10, I11, I12, I13, I3
**Requirement**: same as A14
**Tests**: unit
**Gate**: quick
**Commit**: `feat(mobile-ios): wire navigation for MVP Core screens`

---

## Parallel Execution Map

```
Shared Phase 1 (Sequential): S1 → S2 → S3 → S4 → S5
Shared Phase 2 (Parallel after S5):
  ├── S6 [P] → S7 [P] → S11 [P]
  └── S8 [P] → S9 [P] → S10 [P]

Android (after S3 for tokens):
  A1 (after S1)
  A2 (after S3) → A3,A4,A5,A6 [P]
  A7,A8,A9,A10 [P] (after A6 + matching Shared use case)
  A11,A12 [P] (after A2,A4 + S7,S11)
  A13 [P] (after A2,A6 + S7,S9)
  A14 (sequential, after A3,A7–A13)

iOS mirrors Android exactly: I1,I2→I3–I6[P]→I7–I13[P]→I14
```

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| S1–S2 | 1 concern each (scaffold, CI) | ✅ Granular |
| S3 | 1 concern (token porting), many values but one deliverable file | ✅ Granular (cohesive data file) |
| S4–S5 | 1 concern each | ✅ Granular |
| S6, S8 | 1 domain model + 1 repo interface + 1 client each (cohesive triple) | ✅ Granular |
| S7, S9 | 1 use-case group each (cohesive, same file location) | ✅ Granular |
| S10, S11 | 1 concern each | ✅ Granular |
| A1–A14, I1–I14 | 1 component/screen/nav-graph each | ✅ Granular |

No task creates more than one cohesive deliverable.

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| S1–S5 | sequential chain | Shared Phase 1: S1→S2→S3→S4→S5 | ✅ Match |
| S6 | S5 | Shared Phase 2 | ✅ Match |
| S7 | S6 | Shared Phase 2 | ✅ Match |
| S8 | S5 | Shared Phase 2 | ✅ Match |
| S9 | S8 | Shared Phase 2 | ✅ Match |
| S10 | S8 | Shared Phase 2 | ✅ Match |
| S11 | S7 | Shared Phase 2 | ✅ Match |
| A1 | S1 | Parallel Execution Map | ✅ Match |
| A2 | S3 | Parallel Execution Map | ✅ Match |
| A3–A6 | A2 | Parallel Execution Map | ✅ Match |
| A7 | A6, S9 | Parallel Execution Map | ✅ Match |
| A8 | A5, A6, S9 | Parallel Execution Map | ✅ Match |
| A9, A10 | A6, S9 | Parallel Execution Map | ✅ Match |
| A11 | A2, A3, A4, S7, S11 | Parallel Execution Map | ✅ Match |
| A12 | A2, A4, S7 | Parallel Execution Map | ✅ Match |
| A13 | A2, A6, S7, S9 | Parallel Execution Map | ✅ Match |
| A14 | A3, A7–A13 | Parallel Execution Map | ✅ Match |
| I1–I14 | mirrors A1–A14 exactly, substituting I-prefixed deps | Parallel Execution Map ("iOS mirrors Android exactly") | ✅ Match |

All rows ✅.

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires (per file header) | Task Says | Status |
|---|---|---|---|---|
| S1, S2 | Scaffolding/CI | none | none | ✅ OK |
| S3 | Design tokens | none | none | ✅ OK |
| S4 | Domain scaffold (no logic yet) | none | none | ✅ OK |
| S5–S11 | Domain enums/models/use cases | unit | unit | ✅ OK |
| A2–A13, I2–I13 | Compose/SwiftUI components & screens | unit | unit | ✅ OK |
| A1, I1 | App module wiring, no logic | none | none | ✅ OK |
| A14, I14 | Navigation graph | unit | unit | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (MVP Core scope, Shared/Android/iOS sections above)

- Map view was **not** in MVP Core — `event-discovery`'s spec/design never request it; Stitch's map screens exist but weren't wired to any task above.
- The `BottomNav` Favorites tab (A3/I3) rendered as a stub in MVP Core — Milestone 2 below is what fulfills it.
- GA4 analytics calls remain **not** included anywhere in this file — gated on tracking-spreadsheet approval per ARCHITECTURE §11, same rule as `api.md`.

---

# Milestone 2: Social & Notifications

**Features**: `favorites-social` (FAV-01–26) + `notifications` (NOTIF-01–23), plus `auth-fan-profile`'s previously-`Pending` P2 stories (AUTH-20–24: address/location, favorite genres & radius, notification-preference fields) that Notifications depends on.
**Design refs**: `.specs/features/favorites-social/design.md`, `.specs/features/notifications/design.md`
**API contracts**: `.specs/tasks/api.md` Milestone 2 (T53–T89) — every task below cites the exact endpoint it calls.
**Sequencing note**: cannot start until MVP Core's PRs merge across all 5 submodules (ROADMAP.md's sequential rule), and depends on `api.md`'s Milestone 2 endpoints existing.
**Not in scope here**: Monetization has zero mobile UI per `monetization/design.md`'s own component list ("qor-landingpage... qor-admin..." — no mobile mention) — no task below should add plan/pricing/quota UI.

## Stitch screen reuse for Milestone 2

| Screen | Stitch ID | Reuse |
|---|---|---|
| Meus Favoritos | `d9b7f87492424f9b952270971837bd22` | Favorites-list screen (S17/A-equivalent below) |
| Meu Perfil - Foco Social | `ee5dea95cc384522b7705c2eb44ac552` | The **social** sections of this screen (friends count, social widgets) that MVP Core's scope note on the same screen explicitly deferred — now in scope |

No dedicated Stitch screens exist for friend-requests, in-app share, the social feed (P3), or notification/address settings — those screens are built from the NIGHTLIFE-GV component library already established in MVP Core (buttons, list rows, form fields, `ConsentCapture`-style layout patterns), not invented from nothing.

## Execution Plan — Milestone 2

```
Shared (sequential foundation, then parallel):
  S12 → S13 → S14
  S14 ──┬→ S15 ─┐
        ├→ S16 ─┤
        ├→ S17 ─┼→ S18 [P3]
        └→ S19 ─┘

Android (after matching Shared use cases):
  A2(existing) → A15 (favorite button, modifies EventCard)
  S15,A2 → A16 (friends list + requests screen)
  S17,A2,A6 → A17 (in-app share sheet)
  S18,A2 → A18 [P3] (social feed screen)
  S16,A13(existing) → A19 (notification-prefs + address/radius, modifies ProfileScreen)
  A14(existing) → A20 (nav wiring update, sequential)

iOS mirrors Android: I15–I20, same dependency shape
```

## Task Breakdown — Milestone 2 (Shared)

#### S12: `Favorite`/`Friendship` domain models + repository interfaces + networking client
**What**: KMP-shared models mirroring `api.md` T53/T54's entity shape; `FavoriteRepository`/`FriendshipRepository` interfaces; Ktor client calling `api.md` T80/T81's endpoints.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/social/`
**Depends on**: S5 (existing enums)
**Reuses**: `api.md` T80/T81's exact endpoint contracts
**Requirement**: FAV-01–FAV-17
**Done when**: unit tests (mocked HTTP engine) — favorite toggle idempotent client-side mapping; friend-request duplicate/auto-accept/already-friends responses mapped to distinct domain results
**Tests**: unit
**Gate**: quick

#### S13: `NotificationPreference`/`UserAddress` domain models + repository interfaces + networking client
**What**: KMP-shared models mirroring `api.md` T55/T57; interfaces + Ktor client calling `api.md` T83/T84's endpoints.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/{notification,user}/`
**Depends on**: S5
**Reuses**: `api.md` T83/T84's endpoint contracts
**Requirement**: AUTH-20–AUTH-24
**Tests**: unit
**Gate**: quick

#### S14: `Friendship`/`NotificationTriggerType`/`NotificationChannel` Kotlin enum mirrors
**What**: Same cross-file-contract rule as MVP Core's S5 — case values must match `api.md` T54/T55's exact backed-enum values.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/enum/`
**Depends on**: S5
**Reuses**: `api.md` T54/T55's exact values
**Requirement**: ARCHITECTURE §14.1
**Tests**: unit
**Gate**: quick

#### S15: `ToggleFavorite`/`SendFriendRequest`/`RespondToFriendRequest`/`RemoveFriend`/`ListFriends` shared use-case wrappers
**What**: Thin wrappers around S12's repository, matching `api.md`'s use-case contracts.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/social/usecase/`
**Depends on**: S12
**Reuses**: S12
**Requirement**: FAV-01–FAV-17
**Tests**: unit
**Gate**: quick

#### S16: `UpdatePreferences`/`UpdateNotificationPreference` shared use-case wrappers
**What**: Wrappers around S13's repository for address/radius/genres and notification-channel/trigger toggles.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/{user,notification}/usecase/`
**Depends on**: S13
**Reuses**: S13
**Requirement**: AUTH-20–AUTH-24
**Tests**: unit
**Gate**: quick

#### S17: `GetFriendsInterested`/`ShareEvent` shared use-case wrappers [P2]
**Where**: `mobile/shared/src/commonMain/kotlin/domain/social/usecase/`
**Depends on**: S12
**Reuses**: S12
**Requirement**: FAV-18–FAV-23
**Tests**: unit
**Gate**: quick

#### S18: `GetSocialFeed` shared use-case wrapper [P3]
**Where**: `mobile/shared/src/commonMain/kotlin/domain/social/usecase/GetSocialFeed.kt`
**Depends on**: S12
**Reuses**: S12
**Requirement**: FAV-24–FAV-26
**Tests**: unit
**Gate**: quick

#### S19: Push-notification client registration (FCM token capture)
**What**: `expect`/`actual` FCM token retrieval per platform, registers the device token against `api.md`'s notification-preference endpoint so `FcmPushSender` (api.md T63) has somewhere to send.
**Where**: `mobile/shared/src/commonMain/kotlin/notification/PushTokenRegistrar.kt`, platform `actual` implementations
**Depends on**: S13
**Reuses**: S13
**Requirement**: ARCHITECTURE §6.1 (client side of the FCM adapter)
**Tests**: unit
**Gate**: quick

## Task Breakdown — Milestone 2 (Android)

#### A15: Favorite button on `EventCard` (modifies A2)
**What**: Wire the favorite-icon placeholder already present in MVP Core's `EventCard` (per DISC-05's "favorite action itself gated by login") to S15's `ToggleFavorite`, with an optimistic-toggle animation (icon fill + a quick scale-pulse consistent with `design-system.md` §3's `--ease-beat`).
**Where**: `mobile/androidApp/src/main/kotlin/ui/components/EventCard.kt` (modify)
**Depends on**: S15, A2 (existing)
**Reuses**: A2's existing `EventCard`, S15
**Requirement**: FAV-01–FAV-02
**Done when**: existing A2 Compose UI tests still pass, plus a new test for the toggle interaction
**Tests**: unit
**Gate**: quick

#### A16: Friends list + pending-requests screen
**What**: Accepted friends list (paginated) + incoming pending-requests section with accept/reject actions, built from the existing form/button component library (A5/A6), no dedicated Stitch screen.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/FriendsScreen.kt`
**Depends on**: S15, A2 (existing)
**Reuses**: `FormFields`/CTA buttons (A6), S15's use cases
**Requirement**: FAV-05–FAV-17
**Tests**: unit
**Gate**: quick

#### A17: In-app share sheet [P2]
**What**: Native OS share sheet (device-level, no new component) plus an in-app "share to friend" picker over the friends list, calling S17's `ShareEvent`.
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/ShareSheet.kt`
**Depends on**: S17, A2 (existing)
**Reuses**: A16's friend-list rendering pattern, S17
**Requirement**: FAV-21–FAV-23
**Tests**: unit
**Gate**: quick

#### A18: Social feed screen [P3]
**What**: Reverse-chronological friend-activity feed, entrance-stagger consistent with the `EventCard` grid pattern (A2/A11).
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/SocialFeedScreen.kt`
**Depends on**: S18, A2 (existing)
**Reuses**: A11's list-rendering pattern (existing)
**Requirement**: FAV-24–FAV-26
**Tests**: unit
**Gate**: quick

#### A19: Notification-preference + address/radius additions (modifies `ProfileScreen`, A13)
**What**: Extend the existing basic-fields `ProfileScreen` (A13) with: per-channel toggles, global silence, per-trigger toggles (event-changed/cancelled shown but non-togglable per NOTIF-07); manual-address entry with device-location as an alternative (never required), distinct/revocable location-consent toggle; favorite-genres multi-select; search-radius input. Also renders the social sections of the Stitch `ee5dea95cc384522b7705c2eb44ac552` reference now in scope (friends count, etc.).
**Where**: `mobile/androidApp/src/main/kotlin/ui/screen/ProfileScreen.kt` (modify)
**Depends on**: S16, A13 (existing)
**Reuses**: A13 (existing), S16
**Requirement**: AUTH-20–AUTH-24; Stitch screen `ee5dea95cc384522b7705c2eb44ac552` (social sections)
**Done when**: existing A13 tests still pass, plus new tests for each added toggle/field and the location-consent revoke → falls back to manual address behavior
**Tests**: unit
**Gate**: quick

#### A20: Navigation graph update (sequential, modifies A14)
**What**: Add `FriendsScreen`, `SocialFeedScreen` (P3) to the existing `NavHost` (A14), wire `BottomNav`'s Favorites tab (previously a stub, A3) to a real favorites-list screen (A17: reuses `HomeFeedScreen`'s list pattern filtered to favorites, per Stitch `d9b7f87492424f9b952270971837bd22`).
**Where**: `mobile/androidApp/src/main/kotlin/ui/NavGraph.kt` (modify)
**Depends on**: A15, A16, A17, A18, A19, A14 (existing)
**Reuses**: A14 (existing)
**Requirement**: cross-cutting; Stitch screen `d9b7f87492424f9b952270971837bd22`
**Tests**: unit
**Gate**: quick
**Commit**: `feat(mobile-android): wire Social & Notifications screens into navigation`

## Task Breakdown — Milestone 2 (iOS)

*(Mirrors Android exactly — same requirement IDs, same Stitch reuse, independent SwiftUI implementation, independent commits per ARCHITECTURE §8.10.)*

#### I15: Favorite button on `EventCard` view (modifies I2)
**Where**: `mobile/iosApp/iosApp/UI/Components/EventCard.swift` (modify)
**Depends on**: S15, I2 (existing)
**Requirement**: same as A15
**Tests**: unit
**Gate**: quick

#### I16: Friends list + pending-requests view
**Where**: `mobile/iosApp/iosApp/UI/Screens/FriendsView.swift`
**Depends on**: S15, I2 (existing)
**Requirement**: same as A16
**Tests**: unit
**Gate**: quick

#### I17: In-app share sheet [P2]
**Where**: `mobile/iosApp/iosApp/UI/Screens/ShareSheet.swift`
**Depends on**: S17, I2 (existing)
**Requirement**: same as A17
**Tests**: unit
**Gate**: quick

#### I18: Social feed view [P3]
**Where**: `mobile/iosApp/iosApp/UI/Screens/SocialFeedView.swift`
**Depends on**: S18, I2 (existing)
**Requirement**: same as A18
**Tests**: unit
**Gate**: quick

#### I19: Notification-preference + address/radius additions (modifies `ProfileView`, I13)
**Where**: `mobile/iosApp/iosApp/UI/Screens/ProfileView.swift` (modify)
**Depends on**: S16, I13 (existing)
**Requirement**: same as A19; Stitch screen `ee5dea95cc384522b7705c2eb44ac552`
**Tests**: unit
**Gate**: quick

#### I20: Navigation update (sequential, modifies I14)
**Where**: `mobile/iosApp/iosApp/UI/AppNavigation.swift` (modify)
**Depends on**: I15, I16, I17, I18, I19, I14 (existing)
**Requirement**: same as A20; Stitch screen `d9b7f87492424f9b952270971837bd22`
**Tests**: unit
**Gate**: quick
**Commit**: `feat(mobile-ios): wire Social & Notifications screens into navigation`

## Task Granularity Check — Milestone 2

| Task | Scope | Status |
|---|---|---|
| S12, S13 | 1–2 cohesive domain models + repo + client each | ✅ Granular |
| S14 | 1 concern (enum mirrors) | ✅ Granular |
| S15–S19 | 1 use-case group or concern each | ✅ Granular |
| A15–A20, I15–I20 | 1 component/screen/nav-update each | ✅ Granular |

## Diagram-Definition Cross-Check — Milestone 2

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| S12–S14 | S5 (S14 also S5) | Shared chain | ✅ Match |
| S15, S16, S17, S18 | S12/S13 respectively | Shared parallel block | ✅ Match |
| S19 | S13 | Shared parallel block | ✅ Match |
| A15 | S15, A2 | Android block | ✅ Match |
| A16 | S15, A2 | Android block | ✅ Match |
| A17 | S17, A2 | Android block | ✅ Match |
| A18 | S18, A2 | Android block | ✅ Match |
| A19 | S16, A13 | Android block | ✅ Match |
| A20 | A15–A19, A14 | Android block | ✅ Match |
| I15–I20 | mirrors A15–A20 | "iOS mirrors Android" | ✅ Match |

All rows ✅.

## Test Co-location Validation — Milestone 2

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| S12–S19 | Shared domain models/use cases | unit | unit | ✅ OK |
| A15–A20, I15–I20 | Compose/SwiftUI components & screens | unit | unit | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (all milestones)

- No mobile monetization UI exists anywhere in this file, in any milestone — `monetization/design.md` names only `qor-landingpage`/`qor-admin` as its UI surfaces.
- A15/I15, A19/I19, A20/I20 all modify existing MVP Core files — when executing, confirm the original file's test suite still passes before adding new assertions, same discipline as `api.md`'s Milestone 2/3 modifications.
- GA4 calls remain excluded from every task in this file, across every milestone.

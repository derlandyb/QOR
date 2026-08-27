# Auth & Fan Profile Specification

## Problem Statement

Fans need a low-friction way into QOR — email/password or Google only, by design (PRD non-goal: no Facebook/Instagram) — and a profile that stores what powers personalization (favorite genres, search radius, notification prefs) and what LGPD requires (consent records, and a place to exercise data rights). Without this, there is no account for favorites, friends, or notifications to attach to, and the platform has no lawful basis for the personal data it collects.

## Goals

- [ ] A fan can sign up and log in with either email/password or Google, with no other social login options
- [ ] A fan can recover access via a forgotten-password flow without engineering involvement
- [ ] A fan can view and edit every profile field the PRD specifies, and exercise every LGPD Art. 18 data right, from account settings

## Out of Scope

| Feature | Reason |
|---|---|
| Facebook/Instagram login | PRD non-goal — email/password + Google only for v1 |
| Notification delivery/triggers | This feature captures preference *fields* only; delivery logic is covered by the Notifications feature |
| Nearby-event search itself | This feature captures the address/radius inputs; the search behavior that consumes them is covered by Event Discovery/future search work |
| Friends graph (add/accept/remove, mutual friends) | Covered by the Favorites & Social feature |
| Venue/Promoter registration and login | Separate role, separate admin-panel flow — covered by the Venue/Promoter Admin feature |

---

## User Stories

### P1: Email/password signup ⭐ MVP

**User Story**: As a new fan, I want to create an account with an email and password, so that I can start using QOR without needing a Google account.

**Why P1**: Without an account, no favorites, friends, or notifications are possible — this is the baseline entry point.

**Acceptance Criteria**:

1. WHEN a fan submits the signup form with email, password, birthdate, and required profile fields THEN system SHALL create a `Pending`-verification account and send a verification email.
2. WHEN a fan submits a signup form THEN system SHALL present the Portuguese-language privacy policy and terms of service and require explicit acceptance before account creation (LGPD Art. 7).
3. WHEN the signup form renders any optional consent checkbox THEN system SHALL leave it unchecked by default — no pre-checked consent boxes.
4. WHEN a fan attempts to sign up with an email already registered (via email/password or Google) THEN system SHALL reject the signup with a clear "account already exists" message rather than creating a duplicate.
5. WHEN a fan submits a password that doesn't meet the minimum strength policy THEN system SHALL reject it with a specific reason (not a generic error).

**Independent Test**: Submit the signup form with a new email, accept terms, verify the account is created in `Pending`-verification state and a verification email is sent.

---

### P1: Google signup/login ⭐ MVP

**User Story**: As a new or returning fan, I want to sign up or log in with my Google account, so that I don't need to create and remember a separate password.

**Why P1**: PRD names Google as one of exactly two supported auth methods for v1.

**Acceptance Criteria**:

1. WHEN a fan authenticates via Google and no QOR account exists for that email THEN system SHALL create a new fan account pre-filled from the Google profile (name, email, picture), prompt for the birthdate Google doesn't provide, and present the same terms/consent acceptance step as email/password signup.
2. WHEN a fan authenticates via Google and a QOR account already exists for that email THEN system SHALL log them into the existing account rather than creating a duplicate.
3. WHEN Google sign-in is used THEN system SHALL treat the email as verified without a separate verification email step.

**Independent Test**: Authenticate with a Google account not previously used on QOR, confirm a new account is created with consent captured; repeat with the same Google account and confirm it logs into the same account.

---

### P1: Returning-fan login ⭐ MVP

**User Story**: As a returning fan, I want to log in with whichever method I signed up with, so that I can access my saved favorites and profile.

**Why P1**: Required for any account-gated feature (favorites, friends, notifications) to be usable across sessions.

**Acceptance Criteria**:

1. WHEN a fan submits correct email/password credentials for a verified account THEN system SHALL log them in and start a session.
2. WHEN a fan submits correct email/password credentials for an unverified account THEN system SHALL block login and prompt to verify or resend the verification email.
3. WHEN a fan submits incorrect credentials THEN system SHALL reject login with a generic "invalid credentials" message (not revealing whether the email exists).
4. WHEN a fan's session is valid THEN system SHALL keep them logged in across app restarts until logout or session expiry.

**Independent Test**: Log in with a verified account's correct credentials and confirm a session starts; attempt login with a wrong password and confirm a generic rejection.

---

### P1: Password recovery ⭐ MVP

**User Story**: As a fan who forgot my password, I want to reset it via email, so that I can regain access without contacting support.

**Why P1**: PRD explicitly lists password recovery as required v1 scope.

**Acceptance Criteria**:

1. WHEN a fan requests a password reset for a registered email THEN system SHALL send a time-limited, single-use reset link.
2. WHEN a fan requests a password reset for an email with no account THEN system SHALL show the same confirmation message as a valid request (no account enumeration).
3. WHEN a fan submits a new password via a valid, unexpired reset link THEN system SHALL update the password and invalidate the link.
4. WHEN a fan attempts to reuse an already-used or expired reset link THEN system SHALL reject it and prompt them to request a new one.

**Independent Test**: Request a reset for a known account, follow the link, set a new password, and confirm login works with the new password and the old link no longer works.

---

### P1: View/edit profile ⭐ MVP

**User Story**: As a fan, I want to view and edit my basic profile information, so that my account reflects who I am.

**Why P1**: Baseline account management required alongside auth for the account to be usable.

**Acceptance Criteria**:

1. WHEN a fan opens their profile THEN system SHALL display username, email, phone, birthdate, and profile picture.
2. WHEN a fan edits username, phone, or profile picture THEN system SHALL save the change and reflect it immediately.
3. WHEN a fan attempts to change their email THEN system SHALL require re-verification of the new email before it takes effect.
4. WHEN a fan signed up via Google THEN system SHALL still allow editing username, phone, and profile picture independently of the Google-sourced values.

**Independent Test**: Edit each profile field, reload the profile, and confirm the changes persisted.

---

### P2: Address & location for nearby search

**User Story**: As a fan, I want to provide my address or share my device location, so that future nearby-event search can use it.

**Why P2**: Needed to feed nearby-search, but the search feature itself isn't built yet — this story only covers capturing and consenting to the input.

**Acceptance Criteria**:

1. WHEN a fan is prompted for location THEN system SHALL offer manual address entry as an alternative to device-location permission — never require device location.
2. WHEN a fan grants device-location permission THEN system SHALL request it as a distinct, explicit consent step, separate from the general terms/privacy acceptance at signup (LGPD — not bundled consent).
3. WHEN a fan has previously granted location consent THEN system SHALL let them revoke it from profile settings, after which system SHALL stop using device location and fall back to any manually entered address (or none).
4. WHEN a fan edits their manually entered address THEN system SHALL save the change.

**Independent Test**: Grant location consent, confirm it can be revoked from settings, and confirm manual address entry works as a standalone alternative.

---

### P2: Favorite genres & search radius preferences

**User Story**: As a fan, I want to set my favorite genres and a search radius, so that future discovery features can personalize what I see.

**Why P2**: Supports personalization but isn't required for the baseline discovery loop, which ships without filtering (per Event Discovery's P3 status).

**Acceptance Criteria**:

1. WHEN a fan opens preferences THEN system SHALL let them select one or more favorite genres from the platform's genre list.
2. WHEN a fan sets a search radius THEN system SHALL save it as a numeric distance value for later use by nearby-search features.
3. WHEN a fan has set no favorite genres or radius THEN system SHALL treat this as a valid default state, not an error.

**Independent Test**: Set favorite genres and a radius, reload the profile, and confirm both persisted.

---

### P2: Notification preference fields

**User Story**: As a fan, I want to control which notification channels reach me, so that I'm not overwhelmed with alerts I don't want.

**Why P2**: The PRD requires per-channel opt-out and a global silence option; this story covers only the stored preference values, not delivery/trigger logic (Notifications feature).

**Acceptance Criteria**:

1. WHEN a fan opens notification settings THEN system SHALL let them independently toggle push and email channels.
2. WHEN a fan enables "silence all" THEN system SHALL override per-channel settings and suppress all notifications until turned off.
3. WHEN a fan changes a notification preference THEN system SHALL persist it immediately for the Notifications feature to read.

**Independent Test**: Toggle each channel and the global silence option, reload settings, and confirm the saved state matches.

---

### P2: LGPD data-subject rights

**User Story**: As a fan, I want to access, correct, delete, export, or revoke consent for my data from my account settings, so that I can exercise my LGPD rights without contacting support.

**Why P2**: Legally required (LGPD Art. 18) for v1 launch, but distinct from the core signup/login/profile loop — grouped as its own story since it's a self-contained settings surface.

**Acceptance Criteria**:

1. WHEN a fan requests to view their stored personal data THEN system SHALL present a readable summary or export of what QOR holds about them.
2. WHEN a fan requests data correction THEN system SHALL direct them to the relevant editable profile fields, or provide a correction request path for data not directly editable.
3. WHEN a fan requests account deletion ("right to be forgotten") THEN system SHALL delete or anonymize their personal data and cascade the deletion to dependent records (favorites, friendships) rather than leaving orphaned PII.
4. WHEN a fan requests a data export THEN system SHALL provide their data in a portable format.
5. WHEN a fan revokes a previously given consent (e.g., location) THEN system SHALL stop the corresponding data use going forward, without requiring full account deletion.

**Independent Test**: From account settings, exercise each of view/correct/delete/export/revoke and confirm the expected effect (e.g., deletion actually removes the account and cascades to favorites).

---

## Edge Cases

- WHEN a fan tries to sign up with an email already registered under the other auth method (e.g., email/password exists, they try Google with the same email, or vice versa) THEN system SHALL link to or block duplicate creation of the existing account rather than creating a second one.
- WHEN a fan attempts to log in before verifying their email (email/password path) THEN system SHALL block login and offer to resend verification.
- WHEN a password-reset link is expired or already used THEN system SHALL reject it and require a fresh request.
- WHEN an account is deleted THEN system SHALL cascade-remove or anonymize dependent records (favorites, friendships, notification prefs) so no orphaned PII remains.
- WHEN a fan revokes location consent after previously granting it THEN system SHALL immediately stop using device location, not just for future requests.
- WHEN a fan changes their email THEN system SHALL not treat the new email as active until it is re-verified.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| AUTH-01 | P1: Email/password signup — account creation + verification email | Design | In Design |
| AUTH-02 | P1: Email/password signup — terms/consent acceptance required | Design | In Design |
| AUTH-03 | P1: Email/password signup — no pre-checked consent boxes | Design | In Design |
| AUTH-04 | P1: Email/password signup — duplicate email rejection | Design | In Design |
| AUTH-05 | P1: Email/password signup — password strength validation | Design | In Design |
| AUTH-06 | P1: Google signup/login — new account creation + consent step | Design | In Design |
| AUTH-07 | P1: Google signup/login — existing-account login, no duplicate | Design | In Design |
| AUTH-08 | P1: Google signup/login — email treated as pre-verified | Design | In Design |
| AUTH-09 | P1: Returning-fan login — verified-account login | Design | In Design |
| AUTH-10 | P1: Returning-fan login — unverified-account block | Design | In Design |
| AUTH-11 | P1: Returning-fan login — generic invalid-credentials message | Design | In Design |
| AUTH-12 | P1: Returning-fan login — session persistence | Design | In Design |
| AUTH-13 | P1: Password recovery — reset link issuance | Design | In Design |
| AUTH-14 | P1: Password recovery — no account enumeration | Design | In Design |
| AUTH-15 | P1: Password recovery — successful reset invalidates link | Design | In Design |
| AUTH-16 | P1: Password recovery — expired/reused link rejection | Design | In Design |
| AUTH-17 | P1: View/edit profile — display core fields | Design | In Design |
| AUTH-18 | P1: View/edit profile — edit username/phone/picture | Design | In Design |
| AUTH-19 | P1: View/edit profile — email change requires re-verification | Design | In Design |
| AUTH-20 | P2: Address & location — manual entry alternative to device location | - | Pending |
| AUTH-21 | P2: Address & location — distinct, explicit location consent | - | Pending |
| AUTH-22 | P2: Address & location — revocable location consent | - | Pending |
| AUTH-23 | P2: Favorite genres & radius — persisted preferences | - | Pending |
| AUTH-24 | P2: Notification preference fields — per-channel + global silence | - | Pending |
| AUTH-25 | P2: LGPD data-subject rights — access/correct/delete/export/revoke | Design | In Design |

**ID format:** `AUTH-[NUMBER]`

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 25 total, 0 mapped to tasks, 25 unmapped, 20 In Design ⚠️

---

## Success Criteria

- [ ] A fan can complete signup (either method) and reach a usable, populated profile in one flow
- [ ] Password recovery works end-to-end without support involvement
- [ ] A fan can exercise each LGPD data right (access, correct, delete, export, revoke) from account settings without engineering involvement
- [ ] Zero orphaned PII after account deletion

**✅ Resolved during Design (2026-08-27)**: Full age-gating (enforcing `age_rating` against a fan's age, and any LGPD Art. 14 parental-consent flow) is **deferred past MVP Core**. Birthdate *is* captured at signup now (P1, AUTH-01/AUTH-06/AUTH-17 above) since it's cheap to collect and will be needed once age-gating ships — but MVP Core does not enforce anything against it, and `age_rating` on events (Venue/Promoter Admin feature) stays informational-only for v1.

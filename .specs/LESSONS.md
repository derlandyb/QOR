# LESSONS - auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

_none_

## Candidates (under observation - do NOT load as guidance yet)

Seen once or not yet corroborated. Tracked, not trusted.

### L-001 - When a spec requires preserving existing animation/transition behavior unchanged and the repo has no visual-regression tooling, flag it as a spec-precision gap instead of accepting the author's audit note alone; verify only by confirming no animation-API touches in the diff, and note that this is not equivalent to an executed regression test.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `mobile/iosApp UI refresh tasks` · harmful: 0
- features: nightlife-gv-stitch-refresh
- evidence: REFRESH-03 (T34-T39) (mobile/iosApp UI refresh tasks)
- last seen: 2026-09-10T04:06:34Z

## Quarantined (failed when applied - ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_

# SplitStack Migration Log (Stack → stacks)

## Rules
- Terminal only
- Canonical collection: stacks
- Deprecated: Stack
- No deletions until migration complete

## Log

### Session Start
- Date: Fri 20 Feb 2026 08:35:01 AWST
- Decision: Standardising on 'stacks' collection.
- StackRecord (capital S) is legacy.
- Migration starting.
---

## Session Continuation
- Date: Fri 20 Feb 2026 (afternoon)
- Context: FlutterFlow action flow stabilisation
- Objective: Align frontend action flow with Firestore schema

---

## Firestore Schema Alignment

### Confirmed Canonical Collection
- `stacks` (lowercase) is the canonical collection.
- Any reference to `Stack` (capital S) is legacy and invalid.
- All page parameters must reference `stacks`.

### Page Navigation Fix
- Page3 parameter `docRef` was incorrectly typed to `Stack`.
- Corrected to match `stacks` collection.
- Navigation now passes correct Document Reference.

Status: ✅ Resolved

---

## Participants Architecture Decision (CRITICAL)

### Confirmed Design
Participants MUST NOT be stored as an array inside `stacks`.

Correct structure:

- `stacks` collection
- `participants` collection (separate)

Each participant document will contain:
- `stack_id` (Document Reference → stacks)
- `user_id`
- `amount`
- future metadata

This is a permanent architectural decision.

---

## Action Flow Adjustments

### Action 3 (Backend Call → Update Document)

- MUST NOT update a `participants` field inside `stacks`.
- Any existing attempt to update participants inside stacks is invalid.
- Participants will be created using a separate:
  Backend Call → Create Document → `participants`.

Status: ⚠ Participant creation flow pending implementation.

---

### Action 5 (Update App State → participants list)

- Currently references:
  `participants (List<Data(participants)>)`
- This is temporary and incorrect until participant creation flow exists.
- This action must be revisited and refactored once participants are properly created.

Status: ⚠ Requires future refactor.

---

## Current System State

- stacks collection standardised.
- Page3 parameter type corrected.
- Navigation docRef mismatch resolved.
- Participants stored separately (architecture locked).
- Participant creation flow not yet implemented.

---

## Next Session Starting Point

1. Implement Backend Call → Create Document → `participants`.
2. Remove temporary participants app-state dependency.
3. Connect participants to stack via Document Reference.
4. Validate split logic end-to-end.

Migration ongoing.

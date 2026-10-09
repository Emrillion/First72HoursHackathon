# October 9 usability, hospital billing, and invitations update

## Current verification

- All **17 core tests pass**, including new coverage for local join-code enrollment, supporter permissions, one-use codes, expiry/replacement/revocation, invalid names/codes, and loading existing JSON saves without an invitation.
- Xcode simulator build-for-testing succeeds on the installed iOS 27.0 runtime (iPhone 17 destination). The app deployment target remains iOS 16.0 and device family remains iPhone only.
- Hospital billing is a presentation-only SwiftUI view. Payment and payment-method buttons are disabled; there are no editable payment fields, network calls, billing state mutations, or payment dependencies.
- All **six iPhone 17 / iOS 27.0 UI tests pass**: caregiver journey and persistence, task creation, invalid-code rejection followed by successful join/claim/relaunch, nonfunctional hospital billing, largest-text task actions, and mock service payment failure/retry.
- Visually inspected captured Plan and Hospital billing screens: readable cards, four clear tabs, unclipped invoice labels, and visibly labeled mock payment.
- Source whitespace check passes. No physical-device test was performed for this update.

Codes work only on the current device and require a shared backend/authentication for real cross-device invitations. Physical iPad rehearsal, minimum-iOS runtime testing, and manual VoiceOver/human usability testing remain outstanding for this update. Prior implementation results below are historical, not retests of this change.

---

# Initial iOS implementation verification

Verified locally on October 9, 2026 with Xcode 27.0 (27A266a), Swift 6.4, and the installed iOS 26.5 Simulator runtime. The source deployment target remains iOS 16.0; no iOS 16 runtime is installed, so minimum-version runtime behavior has not been exercised.

## Passed

- Simulator app build, without signing or external dependencies.
- Unsigned physical-device app build using the iOS SDK. This does not establish successful physical installation.
- The built app’s `UIDeviceFamily` contains only `1` (iPhone); `MinimumOSVersion` is `16.0`.
- **14 domain tests** covering accepted ownership, refusal to overwrite claims, permissions and private tasks, payment failure/decline with no partial writes, retry without duplicate receipts, category/resource validation, $0 budget and destination blockers, cancellation and released amounts, completion and undo, persistence, self-coordination, overdue ordering, and a 72-hour recovery window.
- **Four iPhone 17 Pro / iOS 26.5 UI checks:** the complete supporter-claim → coordinator checkout → fulfillment → relaunch flow, task creation, largest-text task actions, and simulated payment failure followed by successful retry. The retry test passed in a targeted rerun after assigning a stable accessibility identifier to its menu picker; the other three passed in the preceding run.
- **Three iPad Pro 13-inch M4 / iOS 26.5 UI checks:** the same full flow, task creation, and task-action reachability at the largest accessibility text size. The same iPhone-targeted app binary is used; there is no tablet-specific target.
- Visual inspection of iPhone and full-display iPad screenshots: supplied branding, single-column compatibility layout, readable task/status labels, and bottom tabs. Large text grows and scrolls rather than using a fixed canvas.
- `git diff --check`.

The initial test on an existing windowed iPad simulator failed to scroll to a task with an application-wide swipe. The harness now scrolls within the app’s scroll view, and the dedicated M4 simulator run passed. XCTest application screenshots were cropped in iPad compatibility mode; screenshot attachments now use `XCUIScreen.main`, and layout was reviewed with a full `simctl` screenshot.

## Still requires a person/device

- Personal Team signing, installation, and rehearsal on the owner’s iPad Pro 13-inch M4 running the reported iPadOS 26.6.1. The installed simulator runtime is 26.5, not that exact version.
- Manual VoiceOver reading order, touch comfort, and a human caregiver timing the journey. Automated UI completion time is not a usability study.
- Real provider suitability, accessibility, location, capacity, funding, and business-model validation. The fixtures disclose limitations; none of those facts are asserted by this demo.

The app is an offline prototype. It has no authentication, live invitations, shared backend, live services, or real payments. Demo role switching is a local presentation tool, not production access control.

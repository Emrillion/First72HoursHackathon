# CareShare — Product and App Design

**Status:** Native prototype with October 9 usability update
**Updated:** October 9, 2026  
**Product promise:** Your recovery, together.

**Implementation note:** The initial native demo is now implemented. See [DEVELOPMENT.md](DEVELOPMENT.md) for what runs locally and [VERIFICATION.md](VERIFICATION.md) for observed checks and remaining device validation. The usability, B2B2C, and local invitation changes below supersede the original navigation and referral-revenue proposals.

## 1. Purpose and source of truth

CareShare helps patients and family caregivers organize non-clinical support during the first 72 hours after hospital discharge. It makes needs, ownership, cost, and completion visible in one place.

This document translates [README.md](README.md) and [HackathonNotes.md](HackathonNotes.md) into a proposed app experience. The iPhone target and same-build iPad demo are confirmed requirements. Screen structure, visual styling, implementation choices, sample prices, and business-model details below are proposals for the MVP, not existing functionality.

The demo must show a caregiver identifying a need, arranging help, understanding who pays and why, and tracking fulfillment in under ten minutes.

## 2. Platform and device decision

- Build a native iOS app primarily for iPhone.
- Use one app target, codebase, and build for the iPhone experience and the iPad demo.
- Retain the portrait, single-column iPhone interface on the demo iPad. A separate iPad build, tablet dashboard, sidebar, or split-view design is outside scope.
- Preferred delivery: an iPhone-targeted app running on iPad in system compatibility mode. Apple documents that this is supported when the app does not depend on iPhone-only device capabilities.
- Configure the targeted device family through Xcode build settings. Avoid unnecessary hardware requirements such as telephony.
- The interface must accommodate supported iPhone widths, safe areas, larger text, and the keyboard; “iPhone format” does not mean a fixed screenshot-sized canvas.
- Confirm the physical demo iPad model, iPadOS version, signing, installation method, and presentation behavior early. Rehearse the same app build on that device before the event.

References: [Apple: test compatible devices](https://developer.apple.com/help/app-review/before-submitting-for-review/test-compatible-devices) and [Apple: UIDeviceFamily](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html).

## 3. People and permissions

| Person | Primary need | Proposed actions |
|---|---|---|
| Patient | Know what is covered and keep control | Create a plan, choose what to share, manage tasks and supporters |
| Caregiver / coordinator | Arrange practical help quickly | Manage an authorized plan, assign responsibilities, arrange services, review costs |
| Supporter | Know exactly how to help | View shared tasks, claim or release their own tasks, record completion |

Patients can coordinate their own plan without a caregiver. A missing support network must not prevent entry into the app; show service and resource options when no supporter is available.

Use explicit plan membership. A supporter should see only information shared with their care circle. Medical records, clinical instructions, diagnosis collection, and treatment recommendations are outside the MVP.

## 4. MVP scope

### Required for the demo

1. Start or open a recovery plan with a discharge date and time.
2. Add practical needs from editable templates or a custom task.
3. View the first 72 hours, including unclaimed and overdue tasks.
4. Show a supporter claiming a task and taking responsibility.
5. Find a sample service for an unmet need and review timing and total cost.
6. Complete a clearly labeled mock payment showing payer, service, amount, and purpose.
7. Return to the plan and show the service arrangement and task completion.

Suggested categories: transportation, meals and groceries, household help, appointment logistics, equipment setup, and caregiver relief. Equipment tasks cover arranging delivery or setup assistance; clinical equipment instructions remain with the care team.

### Later work

Live provider booking, actual payment processing, hospital integrations, cross-device invitations and account provisioning, push notifications, calendar sync, recurring tasks, insurance eligibility, multilingual content, and a dedicated tablet experience.

Basic accessible interaction belongs in the MVP, even though broader accessibility improvements appear in the README's future roadmap.

## 5. Navigation and screens

Use four bottom tabs: **Plan**, **Find Help**, **Circle**, and **Hospitals**. Plan opens by default and prioritizes patients and family caregivers. Hospital business-model information and a strictly nonfunctional billing mockup live in Hospitals. Optional service checkout remains inside Find Help.

| Screen | Content and primary action |
|---|---|
| Welcome / plan setup | “Who are we helping?”, preferred display name, discharge date/time, optional location for services. Primary action: “Create plan.” Provide a demo-plan shortcut. |
| Plan | Recovery-window dates, tasks needing help, upcoming responsibilities, and completion progress. Default: To do (incomplete tasks). Filters: To do, Needs help, Done, All. Collapse recovery-window details and keep task cards concise. Primary action: “Add task.” |
| Add / edit task | Title, category, due date/time, priority, notes, visibility, and optional owner. Keep required fields minimal. Primary action: “Save task.” |
| Task details | What, when, owner, status, notes, and activity. Role-appropriate actions: “I can help,” “Find help,” “Release task,” and “Mark complete.” |
| Find Help | Task-relevant service and resource cards with timing, total price, and location/eligibility notes. Offer “Free / community” and “Paid” filters. |
| Service details | Scope, exclusions, sample availability, price breakdown, cancellation terms, and payer. Primary action: “Review request.” |
| Review and mock payment | Service, time, payer, total, and a plain-language reason for the expense. Primary action: “Confirm demo payment.” |
| Confirmation | “Demo booking confirmed,” service summary, mock receipt, and task link. Say that no money was charged and no real provider was contacted. |
| Circle | Patient/coordinator and supporters, roles, and assigned tasks. Show members, Invite someone, and Have a join code? Move role switching, budget preferences, and reset into Plan & demo settings. Codes work on the current device only. |

Free resource cards must distinguish information or referrals from confirmed availability. Do not mark a task covered merely because someone viewed a resource.

## 6. Core interactions and task states

The first screen should answer: **What needs help next, who is handling it, and what remains uncovered?**

Show overdue, incomplete tasks first, then upcoming unclaimed tasks, then covered tasks by due time. Keep completed tasks accessible without crowding urgent work. Use readable date/time labels alongside relative language such as “Today.”

| State | Meaning | Transition |
|---|---|---|
| Needs help | No confirmed owner or arrangement | A supporter claims it, or a service arrangement is confirmed |
| Claimed | A named person has accepted responsibility | Complete it, or release it back to Needs help |
| Arranged | A service is confirmed; in the demo this is simulated | Record fulfillment, or cancel and return to Needs help |
| Completed | A named person recorded completion and time | Coordinator can reopen it with an activity entry |

“Overdue” and priority are independent indicators, not ownership states. Payment success does not imply the task was completed.

Claiming updates the task owner and activity immediately. If another person has already claimed a task, show the current owner and prevent overwriting. In the demo, switching between seeded roles must show the same underlying task state.

Cancelling checkout must preserve the task and leave it needing help. A failed mock payment offers retry and does not create an arranged task or duplicate receipt. Completion should have an undo path.

The recovery window begins at the entered discharge timestamp and spans 72 hours. Tasks remain accessible after that window; overdue needs do not disappear.

## 7. Visual and accessibility direction

**Tone:** calm, capable, welcoming. Use short sentences and familiar words. Prefer “Needs help” over internal workflow terminology.

**Proposed palette:** warm off-white background, white surfaces, deep teal primary actions, dark slate text, amber attention indicators, and green completion indicators. Final color values must pass contrast checks before implementation.

**Layout:** single-column cards, generous spacing, clear section labels, and one prominent primary action per screen. Start with a 16-point horizontal margin and an 8-point spacing rhythm. Avoid dense tables in the app.

**Typography:** system font with Dynamic Type. Prioritize task title, due time, and owner. Allow text to wrap; do not truncate essential instructions or amounts.

**Interaction requirements:**
- Minimum 44 × 44-point touch targets as a design requirement.
- VoiceOver labels and logical reading order for task cards, status, cost, and actions.
- Text and icons in addition to color for every status.
- Visible labels for inputs, clear validation near the field, and preserved form entries after errors.
- Scrollable forms with reachable actions when the keyboard or larger text is active.
- No essential drag gestures, timed interactions, or motion-dependent feedback.

## 8. Payment and service model

The hackathon requires a convincing payment experience without taking money. All providers, availability, prices, bookings, and receipts in the demo must be labeled as sample or simulated.

**Proposed demo transaction:** a family caregiver pays $24 for a meal delivery because no supporter is available to prepare dinner. Example breakdown: meal $18 + delivery $6 = $24, with no additional charges in this fixture. These are invented demo values, not market quotes.

Show the payer by name before confirmation. If someone else is selected as payer, require their approval in a future live implementation; the demo can use a seeded authorized payer. Do not collect real card numbers.

**Confirmed model: B2B2C.** CareShare provides the platform to hospitals; hospitals introduce it to patients and family caregivers. The proposed commercial mechanism is a hospital subscription with no patient platform fee. The billing mockup shows a fictional $499 monthly invoice, static example card, and disabled payment action; pricing is illustrative. It collects no payment details and creates no transaction. Optional third-party meals and rides remain separate sample expenses, with no assumed hospital or insurance funding.

## 9. Implementation outline

**Proposed stack:** SwiftUI with a local persisted demo store and a small service abstraction. Confirm minimum iOS version against the actual demo hardware before creating the app project.

Views should use shared plan/task state. Put booking and payment behavior behind replaceable interfaces so mock behavior can later be replaced without redesigning screens.

| Entity | Minimum fields |
|---|---|
| RecoveryPlan | ID, patient display name, discharge timestamp, timezone, member IDs |
| Member | ID, display name, role, plan membership |
| Task | ID, plan ID, title, category, due timestamp, priority, notes, visibility, owner ID, status |
| ServiceOption | ID, sample provider, service category, scope, sample time, price breakdown, eligibility notes |
| Arrangement | ID, task ID, service ID, payer ID, requested time, status, demo flag |
| PaymentRecord | ID, arrangement ID, payer, amount, currency, simulated status, receipt reference |
| Activity | ID, task ID, actor ID, event, timestamp |
| PlanInvitation | Random eight-character code, plan ID, 24-hour expiry; optional for saved-data compatibility |

Use fictional people and addresses in the demo. Persist local changes across relaunches and provide a deliberate “Reset demo” action. Join codes persist locally, admit a named supporter, and switch the demo perspective to that supporter. Each code is single-use, expires after 24 hours, can be revoked, and is invalidated by generation of a replacement. Only patients and coordinators generate codes; supporters cannot see private tasks. Codes do not authenticate people or connect devices; real cross-device sync and authentication remain future work.

In a production implementation, enforce membership and permissions in the backend, not only in the UI. Collect the minimum information needed to arrange practical support.

## 10. Demo script

Target a 6–8 minute walkthrough, leaving room below the ten-minute requirement.

1. Open a seeded plan for a fictional patient discharged earlier today.
2. Show the next 72 hours and identify uncovered dinner and transportation tasks.
3. Switch to a supporter and claim transportation; return to the coordinator to show the named owner.
4. Open the dinner task and select “Find help.”
5. Review the sample meal delivery, total price, payer, and reason for purchase.
6. Confirm the mock payment and show the demo receipt.
7. Return to Plan: dinner is Arranged and transportation is Claimed.
8. Simulate fulfillment, record completion, and show who completed the task and when.
9. In Circle, generate a join code, then enter it with a fictional supporter name on the same device.
10. Show Hospitals to explain B2B2C and open the disabled hospital billing mockup.

Set seed times relative to demo reset so the walkthrough stays coherent on event day. Keep the demo usable without live provider APIs or external payment services.

## 11. Acceptance checklist

- [ ] The same iPhone-targeted app build installs and runs on an iPhone and the physical demo iPad.
- [ ] The iPad presents the iPhone flow without requiring a separate layout or app target.
- [ ] A caregiver finishes the scripted need-to-arrangement journey in under ten minutes.
- [ ] Adding, claiming, releasing, arranging, completing, and reopening tasks produce consistent visible state.
- [ ] An uncovered or overdue task remains easy to find.
- [ ] Payer, service, total, and purpose appear before mock payment confirmation.
- [ ] Mock payment success, failure, retry, and cancellation preserve correct task and receipt state.
- [ ] A confirmed arrangement remains distinct from completed fulfillment.
- [ ] Larger text, VoiceOver, keyboard presentation, and touch targets are checked on the core flow.
- [ ] Relaunch preserves progress; Reset demo restores a coherent scenario.
- [ ] The flow works for a patient with no seeded supporters.
- [ ] Demo labels make simulated providers, bookings, and payments clear.
- [ ] Local join codes reject invalid, expired, replaced, revoked, and reused codes without changing membership.
- [ ] Existing saved plans still load after the update.
- [ ] Hospitals explains who pays; billing is visibly nonfunctional and cannot collect payment details.

These are implementation acceptance criteria; no app build or device testing has been completed by creating this document.

## 12. Decisions still to resolve

- Physical demo iPad model/iPadOS version and installation/signing method.
- Minimum supported iOS version and final visual palette.
- Which service category best demonstrates the team’s value proposition; meals are the initial proposal.
- Whether live shared accounts and invitations are feasible after the single-device prototype.
- Real provider coverage, payment authorization, cancellation/refund rules, and revenue model for a later release.

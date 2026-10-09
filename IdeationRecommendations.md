# First 72 Hours: ideation recommendations

Prepared October 9, 2026 from `HackathonNotes.md` and the primary sources linked below. No direction has been selected. All prices, partners, funding, and demo timings below are proposed assumptions, not market quotes or established agreements.

## Recommended direction

Build a **72-hour support plan that turns two urgent needs into funded, confirmed arrangements**. Start with meals and transportation. Add a family check-in assignment only if time permits.

Working pitch: “In under ten minutes, know who is bringing food, who is handling tomorrow’s ride, what your family will pay, and what happens if someone cannot follow through.”

The notes emphasize fragmented resources, limited money, unequal circumstances, and accountability. Reduce decisions and follow-up work for the caregiver. Every arrangement needs a deadline, an accepted owner, a funding source, and a visible outcome.

## Options and tradeoffs

These rankings are product judgments against the supplied rubric, not predicted judge scores.

| Direction | Caregiver value | Demo/payment strength | Main weakness | Recommendation |
| --- | --- | --- | --- | --- |
| 72-hour essentials plan: meals + ride + ownership | Resolves connected problems in one journey | Shows prioritization, funding, booking, and failure recovery | Scope expands quickly | Best overall; limit to two service types |
| Ride Ready: one appropriate ride with a backup | Specific need highlighted by the speaker | Clearest booking and payment demonstration | Accessibility and availability need explicit handling | Best fallback if build time is short |
| Care Circle: relatives claim tasks and contribute | Gives each task an accountable person | Easy task acceptance and contribution ledger | Assumes a support network; payment can feel bolted on | Useful feature within the essentials plan |
| Benefits/resource navigator | Helps find affordable support | Strong affordability story | Eligibility and turnaround are uncertain; a list leaves work with the caregiver | Supporting capability, not the core demo |

Avoid leading with a generic chatbot, discharge-summary generator, or nationwide marketplace: each makes it harder to demonstrate the specific journey requested.

## Existing services and positioning

Findhelp advertises screening, referrals, and tracking of fulfilled needs. Its broader offering includes a goods-and-services marketplace. Connecting people to resources and tracking referrals is therefore insufficient differentiation. [Findhelp platform](https://company.findhelp.com/products/platform/), [Findhelp overview](https://company.findhelp.com/).

211 helps identify transportation resources and local food assistance. It is a plausible discovery or human-help route; its public pages do not establish that a particular provider has capacity tonight. [211 transportation assistance](https://211.org/get-help/healthcare-expenses), [211 food assistance](https://211.org/get-help/food-programs-food-benefits).

The proposed distinction is a deliberately short caregiver workflow for a specific discharge window: urgent tasks, usable service times, visible family cost, accepted responsibility, and a fallback. This is a positioning hypothesis, not a claim that competitors lack these functions. Investigate existing networks as potential partners before rebuilding a directory.

## Seven-to-eight-minute demo

Use a fictional caregiver who works tomorrow, has $20 available, and needs food tonight plus a ride for an already scheduled appointment. The patient has returned home. Diagnosis prediction is outside this product's purpose.

1. **Understand the situation — 90 seconds.** Ask location, timing, unresolved tasks, spending limit including $0, language, and available help. Ask transportation accessibility and food constraints when relevant. Allow “I'm not sure.”
2. **Review two arrangements — two minutes.** Recommend one option and offer one alternative per need. Explain fit: location, deadline, stated requirements, and price. A free service arriving too late does not solve tonight's problem.
3. **Confirm ownership and funding — two minutes.** Show an itemized total and each payer's share; approve a mock checkout. A family helper must accept before a task is treated as assigned.
4. **See the plan — one minute.** Show today/tomorrow/next day, service windows, owner, cost, and fallback. Distinguish requested, confirmed, and completed.
5. **Recover from failure — one minute.** A mock provider declines the ride. Reopen the need, show a suitable backup and any price change, and request approval before confirming a replacement.

Confirm the judges' interpretation of “fulfillment”: real food delivery cannot happen during a short table demo. Show functioning booking and clearly labeled simulated provider acceptance and completion.

The strongest demo moment is a cancellation that produces a concrete next action rather than quietly leaving the caregiver with an unresolved need.

## Payment and business model

Assume a hospital pilot sponsor has explicitly authorized a limited support budget. This is a buyer hypothesis to validate. Pending grants and unverified insurance eligibility are not approved funding.

| Item | Total | Family pays | Pilot sponsor pays |
| --- | ---: | ---: | ---: |
| Three prepared meals | $36 | $12 | $24 |
| One appropriate ride | $48 | $8 | $40 |
| Coordination fee | $10 | $0 | $10 |
| **Total** | **$94** | **$20** | **$74** |

The family contributes its chosen $20 toward services. The sponsor pays $64 toward services and a $10 coordination fee under the assumed agreement. Of the $94, $84 is service pass-through and $10 is platform revenue before costs. Pricing and profitability are unvalidated.

The buyer hypothesis is that a hospital values less manual follow-up and better visibility into unresolved support. Validate that proposition; do not claim proven savings or fewer readmissions from a prototype.

Show funding source, authorization status, and remaining balance. For a $0-budget caregiver, use confirmed sponsor funding or an accepted no-cost service where available. If neither exists, show the shortfall and a human-help route; do not mark the plan funded. Cancellation should release the simulated authorization, and changed family charges require approval. Collect no actual card details.

## MVP boundaries

Build five simple views: intake, proposed plan, mock checkout, task board, and provider/demo controls. Seed one service area with a handful of clearly fictional providers, capacity limits, and one unavailable option. Persist enough state that refreshing does not lose the plan.

Record each need's deadline, service constraints, provider/helper, accepted owner, cost, payer allocation, status, and fallback. Record who reports completion; provider reports and caregiver confirmation are separate evidence.

AI can turn free text into editable non-clinical needs or explain a match. Keep prices, availability, service constraints, eligibility rules, and totals in structured data. Have the caregiver confirm extracted information. A form-based journey is sufficient if AI adds complexity without improving the experience.

Defer live payments, real hospital integrations, nationwide coverage, automated benefits adjudication, document uploads, medical recommendations, and a large provider portal.

## Inclusion in the actual flow

- Ask “Where will you be staying?” rather than assuming a permanent home. If no suitable destination exists, show that unresolved issue and a human support route before scheduling delivery. A listing is not a confirmed place to stay.
- Allow self-coordination and “no available helper”; inviting relatives must not be required.
- Make $0 a normal budget choice. Match deadlines and requirements within confirmed funding.
- Use plain language, large controls, and explicit status text. Review the actual journey in any second language used in the demo.
- Ask concrete questions such as “Can you prepare the food available tonight?” A pantry listing may not solve a prepared-meal need.
- Collect only information needed for the arrangement; share task-specific details after the caregiver approves the handoff.

## Validate before expanding

Ask a caregiver what they actually arranged on the first night, what failed, and who handled it. Ask a discharge coordinator which tasks consume follow-up time and what happens after hours. Ask a provider what it needs to confirm a slot and how quickly it can respond. Ask a potential sponsor who controls a support budget and whether it would fund services, coordination, or both.

Test with someone unfamiliar with the prototype: can they arrange both needs without coaching in under ten minutes, identify their exact cost, and explain what remains unconfirmed? Repeat with no available money and a declined provider. Measure time to confirmed arrangements, unresolved needs, payment comprehension, and recovery from failure. These are prototype outcomes; clinical outcomes require separate evaluation.

The remaining build time, team capabilities, intended locality, available partnerships, and judges' interpretation of simulated fulfillment materially affect scope. If both meal and transport flows cannot be completed reliably, build Ride Ready with the same funding and accountability mechanics.

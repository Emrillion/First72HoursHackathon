# Run CareShare locally

CareShare now has a dependency-free SwiftUI demo for iPhone, with the same app running on iPad in iPhone compatibility mode. Open `CareShare.xcodeproj`, select the **CareShare** scheme, choose an iPhone simulator, and Run. The deployment target is iOS 16.0. Xcode 27 is installed on the development Mac.

The tabs are **Plan**, **Find Help**, **Circle**, and **Hospitals**. Plan shows incomplete tasks first; completed tasks are available under Done. Circle focuses on people and invitations, with role switching and reset in **Plan & demo settings**. Hospitals explains B2B2C and displays a nonfunctional billing mockup. Task acceptance and the separate $24 mock service checkout remain available. The existing brand kit supplies the mark, icon, and palette; app typography uses the system font and Dynamic Type. All data, providers, payments, and acceptance are fictional, local, and simulated. No network, login, payment account, or third-party packages are required.

## Demo on the iPad

The intended physical device is an **iPad Pro 13-inch (M4), iPadOS 26.6.1**, as reported by the project owner. Physical installation and rehearsal are still required. The app target uses `TARGETED_DEVICE_FAMILY = 1`, portrait orientation, and no iPhone-specific hardware requirements. Do not change it to a universal tablet layout without revisiting the agreed design.

A paid Apple Developer Program membership is not needed for personal on-device testing. In Xcode Settings → Accounts, sign in with your Apple Account. In the CareShare target’s Signing & Capabilities, select your **Personal Team** and keep automatic signing enabled. If Xcode reports a bundle identifier conflict, choose a unique identifier. Connect and trust the iPad, select it as the Run destination, enable Developer Mode if prompted, and Run. No account or team identifier is committed to this repository.

Apple’s free Personal Team provisioning expires after seven days. Rebuild/reinstall close to the event and rehearse on the physical device. Personal Team signing does not provide App Store or TestFlight distribution. See [Apple’s membership comparison](https://developer.apple.com/support/compare-memberships/) and [compatible device guidance](https://developer.apple.com/help/app-review/before-submitting-for-review/test-compatible-devices).

## Six-to-eight-minute demo

1. Launch and tap **Explore the demo plan**. Sam Morgan has four practical tasks with deadlines relative to now. Alex Morgan is the coordinator; Jordan Lee is a supporter. The fictional spending limit starts at $60.
2. Open **Circle → Plan & demo settings**, choose **Jordan Lee**, return to **Plan**, open the ride task, and tap **I can help**. The accepted owner is now visible.
3. Return to **Circle → Plan & demo settings** and choose **Alex Morgan**. In Plan, open dinner and choose **Find help for this task**.
4. Open **Dinner, taken care of**. Review scope and exclusions, confirm the sample fit, then **Review request**.
5. Show the payer, timing, $18 meal + $6 delivery = **$24**, and purpose. Tap **Confirm demo payment**. Simulated payment and provider acceptance produce one receipt and an **Arranged** task. No money moves.
6. Open **View arranged task**, then **Record simulated fulfillment**. The activity records who reported completion and when. Use **Reopen task / undo completion** to reverse completion.
7. Reset deliberately in Circle → Plan & demo settings before the next walkthrough. **Try a plan without supporters** demonstrates self-coordination.

## Failure and inclusion checks

- Checkout’s **Demo controls** can fail payment or decline the provider. Neither creates a receipt, payment, or arrangement. Choose Success and retry.
- Backing out of checkout leaves the need unchanged. Repeated confirmation is rejected by the domain model after the first successful booking.
- Cancelling an arranged service returns it to Needs help and releases the simulated payment. Any replacement requires another explicit approval.
- In Circle → Plan & demo settings, set the spending limit to $0. Paid checkout is blocked; sample community resources remain informational. They never create a booking or assume available funding.
- Unconfirm the place-to-stay setting to block service bookings while retaining tasks. The flow directs the user to human support; it does not invent a destination.
- The demo includes standard meal/ride fixtures only. Dietary, mobility, location, eligibility, and real-time capacity matching are not implemented; scope and exclusions are shown before the user reviews a request.
- Tasks outside the first 72 hours remain accessible. Overdue tasks sort first; completion is separate from ownership and booking.
- Roles share the same local store. Supporters see shared tasks, may claim open tasks and release/complete their own, and cannot pay or manage plan preferences. Private tasks remain visible to patient/coordinator only. This is not production authentication.

## Source layout

- `CareShare/Core/Models.swift`: persisted entities and fictional service catalog.
- `CareShare/Core/DemoState.swift`: permissions, lifecycle, payment/booking transitions, replaceable booking interface, JSON persistence.
- `CareShare/UI/`: SwiftUI views and transactional observable store. Changes are shown only after the atomic file save succeeds.
- `Tests/CareShareCoreTests/`: domain regression tests, runnable on macOS without a simulator.
- `CareShareUITests/`: actual app journey and task creation through XCTest UI automation.
- `scripts/generate-project.py`: standard-library-only project generator. The generated `.xcodeproj` is checked in; running the script is only necessary when regenerating file references.

Saved state lives in the app sandbox under `Application Support/CareShare/demo-plan.json`. UI tests use a separate `ui-test.json` file. `--reset-demo` seeds a fresh plan; `--uitesting` selects test persistence. Reset replaces all local demo tasks and receipts after confirmation. A corrupt file produces an error instead of silently overwriting the saved plan on launch.

## Checks

See [VERIFICATION.md](VERIFICATION.md) for the recorded results and remaining device/manual checks.

```sh
swift test
xcodebuild -project CareShare.xcodeproj -scheme CareShare \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project CareShare.xcodeproj -scheme CareShare \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO test
```

Choose an installed simulator from `xcrun simctl list devices available`. To run on an iPad simulator, change the destination while keeping the same scheme and app target.

Live accounts, cross-device invitations/sync, provider APIs, automatic funding/eligibility, push notifications, translations, and live payment processing remain out of scope. The B2B2C model has hospitals paying for platform access and distributing CareShare to patients/families. Subscription terms and $499/month pricing are invented examples, not real commercial agreements.

## Local join-code walkthrough

In Circle, select **Invite someone → Generate join code** as the patient or coordinator. Note the eight-character code and close the sheet. Select **Have a join code?**, enter that code and a new fictional display name, then **Join care plan**. Membership is persisted and the active perspective changes to the new supporter. Open Plan to claim a shared task. The code is consumed after one successful use; expiry (24 hours), replacement, and revocation also invalidate it. Invalid input leaves membership unchanged. Return to a coordinator through Plan & demo settings to create another invitation.

These codes are deliberately limited to the plan saved on this device. They cannot invite someone on another phone; that requires shared backend storage and authentication. The interface states this limitation before generating or entering a code. Existing JSON saves without an invitation still load.

## Hospital payment mockup

Open **Hospitals → View hospital billing mockup**. The screen displays a fictional organization, platform subscription, invoice, example card, and disabled payment controls. It has no editable payment fields, payment processor, billing persistence, network calls, or success flow. Hospital billing does not change the patient's service budget or task state. Optional meal/ride service costs remain separate from the hospital platform subscription.

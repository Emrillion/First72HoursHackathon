import SwiftUI

/// Presentation only. No payment SDK, input fields, network calls, or persisted billing state.
struct HospitalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Better support,\nbeyond discharge.").font(.largeTitle.bold())
                Text("Hospitals bring CareShare to patients and the people who care for them.").foregroundStyle(CareTheme.muted)
                CareCard {
                    Label("Our B2B2C model", systemImage: "building.2.crop.circle").font(.title3.bold())
                    Text("Business → Business → Consumer").font(.subheadline).foregroundStyle(CareTheme.muted)
                    modelStep("1", title: "CareShare equips hospitals", detail: "Hospitals pay for access to the care coordination platform.")
                    modelStep("2", title: "Hospitals connect patients", detail: "The discharge team introduces CareShare and helps patients start a plan.")
                    modelStep("3", title: "Families coordinate care", detail: "Patients invite their circle, share everyday tasks, and see who is helping.")
                }
                CareCard {
                    Text("Who pays for what?").font(.title3.bold())
                    Label("Hospital: platform subscription", systemImage: "building.2")
                    Label("Patients & families: no platform fee", systemImage: "person.2")
                    Text("Optional meals, rides, and other services may have separate costs. A hospital subscription does not promise service funding or insurance coverage.")
                        .font(.callout).foregroundStyle(CareTheme.muted)
                }
                NavigationLink { HospitalBillingView() } label: { Text("View hospital billing mockup") }
                    .buttonStyle(PrimaryButton()).accessibilityIdentifier("hospitalBilling")
                Text("Business model presentation · example terms only").font(.footnote).foregroundStyle(CareTheme.muted)
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("For hospitals").navigationBarTitleDisplayMode(.inline)
    }

    private func modelStep(_ number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number).font(.headline).frame(width: 32, height: 32).background(CareTheme.mint).clipShape(Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(CareTheme.muted)
            }
        }.padding(.vertical, 6)
    }
}

struct HospitalBillingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CareCard {
                    Label("UI mockup · payments disabled", systemImage: "eye").font(.headline)
                    Text("Nothing here can charge money or save payment details. All hospital and billing information is fictional.")
                        .font(.callout).foregroundStyle(CareTheme.muted)
                }
                CareCard {
                    Text("Meadowbrook Hospital").font(.title2.bold())
                    Text("EXAMPLE ORGANIZATION").font(.caption.bold()).foregroundStyle(CareTheme.muted)
                    Divider()
                    Text("CareShare Partner").font(.headline)
                    Text("Monthly platform subscription").font(.subheadline)
                    Text("$499 / month").font(.largeTitle.bold())
                    Text("Illustrative pricing, not an offer. Includes patient care plans, care circle invitations, and task coordination.")
                        .font(.callout).foregroundStyle(CareTheme.muted)
                }
                CareCard {
                    Text("Invoice preview").font(.title3.bold())
                    billingRow("Billed to", "Meadowbrook Hospital")
                    billingRow("Invoice", "SAMPLE-001")
                    billingRow("Billing period", "One month")
                    billingRow("Platform access", "$499.00")
                    billingRow("Tax (sample)", "$0.00")
                    Divider()
                    billingRow("Example total", "$499.00")
                    Text("Purpose: provide CareShare access for discharged patients and their caregivers.").font(.callout)
                }
                CareCard {
                    Text("Payment method preview").font(.title3.bold())
                    Label("Corporate card · •••• 4242", systemImage: "creditcard")
                    Text("Example card · no account connected").font(.footnote).foregroundStyle(CareTheme.muted)
                    Button("Change payment method") {}.disabled(true).frame(minHeight: 44)
                }
                Button("Pay $499.00 — mockup only") {}.buttonStyle(PrimaryButton()).disabled(true)
                    .accessibilityIdentifier("hospitalPayDisabled")
                Text("Payment is intentionally unavailable. This screen never creates a payment, receipt, or subscription.")
                    .font(.footnote).foregroundStyle(CareTheme.muted)
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Hospital billing").navigationBarTitleDisplayMode(.inline)
    }

    private func billingRow(_ title: String, _ value: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) { Text(title); Spacer(); Text(value).fontWeight(.semibold) }
            VStack(alignment: .leading, spacing: 4) { Text(title); Text(value).fontWeight(.semibold) }
        }.font(.subheadline)
    }
}

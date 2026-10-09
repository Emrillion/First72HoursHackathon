import SwiftUI

@main
struct CareShareApp: App {
    @StateObject private var store = AppStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store)
                .tint(CareTheme.teal).foregroundStyle(CareTheme.ink)
                .preferredColorScheme(.light)
                .alert("Let’s take another look", isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                )) { Button("OK", role: .cancel) { store.errorMessage = nil } }
                message: { Text(store.errorMessage ?? "") }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        if store.state.plan == nil {
            WelcomeView()
        } else {
            TabView {
                NavigationStack { PlanView() }
                    .tabItem { Label("Plan", systemImage: "checklist") }
                NavigationStack { FindHelpView() }
                    .tabItem { Label("Find Help", systemImage: "hands.sparkles") }
                NavigationStack { CircleView() }
                    .tabItem { Label("Circle", systemImage: "person.2") }
            }
        }
    }
}

struct WelcomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var name = ""
    @State private var discharge = Date()
    @State private var location = ""
    @State private var hasDestination = true
    @State private var selfCoordinating = false
    @State private var budget = "60"
    private var validBudget: Int? { Int(budget).flatMap { (0...10000).contains($0) ? $0 * 100 : nil } }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Image("BrandSymbol").resizable().scaledToFit().frame(width: 64, height: 64).accessibilityHidden(true)
                        Text("A little support.\nA lot less to carry.").font(.largeTitle.bold())
                        Text("Make a plan for the everyday things in the first 72 hours home.").foregroundStyle(CareTheme.muted)
                        DemoNotice()
                    }.padding(.vertical, 16)
                    Button("Explore the demo plan") { store.reset() }
                        .buttonStyle(PrimaryButton()).accessibilityIdentifier("exploreDemo")
                }
                Section("Or start a fictional plan") {
                    TextField("Patient display name", text: $name).textContentType(.nickname)
                    DatePicker("Discharged", selection: $discharge, in: ...Date())
                    Toggle("I’m coordinating for myself", isOn: $selfCoordinating)
                    TextField("Where will you be staying? (optional)", text: $location)
                    Toggle("I have a confirmed place to stay", isOn: $hasDestination)
                    if !hasDestination {
                        Text("You can still organize tasks. Ask your discharge coordinator or a local support worker to help confirm a safe destination before arranging a delivery or ride.")
                            .font(.callout).foregroundStyle(CareTheme.amber)
                    }
                    HStack {
                        Text("Spending limit (USD)")
                        TextField("0", text: $budget).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                            .accessibilityLabel("Spending limit in dollars")
                    }
                    Text("$0 is welcome. Sample community resources never count as confirmed help.").font(.footnote)
                    if validBudget == nil { Text("Enter a whole-dollar amount from 0 to 10,000.").foregroundStyle(CareTheme.amber) }
                    Button("Create plan") {
                        guard let cents = validBudget else { return }
                        store.change { $0 = .newPlan(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                                     discharge: discharge, location: location, hasDestination: hasDestination,
                                                     budgetCents: cents, selfCoordinating: selfCoordinating) }
                    }.buttonStyle(PrimaryButton())
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || validBudget == nil)
                }
            }.scrollContentBackground(.hidden).background(CareTheme.cloud)
                .navigationTitle("CareShare").navigationBarTitleDisplayMode(.inline)
        }
    }
}

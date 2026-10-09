import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var store: AppStore
    let taskID: UUID
    @State private var editing = false
    @State private var confirmingCancel = false
    private var task: CareTask? { store.state.visibleTasks().first { $0.id == taskID } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let task {
                    CareCard {
                        StatusBadge(status: task.status)
                        Text(task.title).font(.largeTitle.bold())
                        Label(task.category.rawValue, systemImage: task.category.symbol)
                        Label(task.due.careDate, systemImage: "clock")
                        if task.isOverdue(at: Date()) { Text("Overdue · this need stays visible until completed.").foregroundStyle(CareTheme.amber) }
                        if !task.notes.isEmpty { Text(task.notes).foregroundStyle(CareTheme.muted) }
                        Divider()
                        Text("Who’s helping").font(.headline)
                        Text(store.state.ownerName(for: task))
                        Text("Shared with: \(task.visibility.rawValue)").font(.footnote).foregroundStyle(CareTheme.muted)
                    }
                    if task.status == .needsHelp {
                        Button("I can help") { store.change { try $0.claim(taskID) } }
                            .buttonStyle(PrimaryButton()).accessibilityIdentifier("claimTask")
                        if store.state.canCoordinate {
                            NavigationLink { FindHelpView(taskID: taskID) } label: { Label("Find help for this task", systemImage: "hands.sparkles").frame(maxWidth: .infinity, minHeight: 48) }
                                .accessibilityIdentifier("findTaskHelp")
                        }
                    }
                    if task.status == .claimed && (task.ownerID == store.state.activeMemberID || store.state.canCoordinate) {
                        Button("Record completion") { store.change { try $0.complete(taskID) } }.buttonStyle(PrimaryButton()).accessibilityIdentifier("completeTask")
                        Button("Release task") { store.change { try $0.release(taskID) } }.frame(maxWidth: .infinity, minHeight: 44)
                    }
                    if task.status == .arranged && store.state.canCoordinate {
                        Text("The sample provider accepted. This does not mean the task is complete.").font(.callout).foregroundStyle(CareTheme.muted)
                        Button("Record simulated fulfillment") { store.change { try $0.complete(taskID) } }.buttonStyle(PrimaryButton()).accessibilityIdentifier("completeTask")
                        Button("Cancel demo arrangement", role: .destructive) { confirmingCancel = true }.frame(minHeight: 44)
                    }
                    if task.status == .completed && store.state.canCoordinate {
                        Button("Reopen task / undo completion") { store.change { try $0.reopen(taskID) } }.frame(minHeight: 48).accessibilityIdentifier("reopenTask")
                    }
                    if let arrangement = store.state.activeArrangement(for: taskID),
                       let payment = store.state.payments.first(where: { $0.arrangementID == arrangement.id }) {
                        CareCard {
                            Label("Demo receipt", systemImage: "receipt").font(.headline)
                            Text(payment.receipt).font(.subheadline.monospaced())
                            Text("\(store.state.members.first { $0.id == payment.payerID }?.name ?? "Demo payer") · \(payment.amountCents.dollars)")
                            Text("No money was charged. No real provider was contacted.").font(.footnote).foregroundStyle(CareTheme.muted)
                        }
                    }
                    CareCard {
                        Text("Activity").font(.title3.bold())
                        let history = store.state.activity.filter { $0.taskID == taskID }.reversed()
                        if history.isEmpty { Text("This need was added to the demo plan. No one has accepted it yet.").foregroundStyle(CareTheme.muted) }
                        ForEach(Array(history)) { event in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.event).font(.callout)
                                Text("\(store.state.members.first { $0.id == event.actorID }?.name ?? "Demo member") · \(event.timestamp.careDate)")
                                    .font(.footnote).foregroundStyle(CareTheme.muted)
                            }.padding(.vertical, 4)
                        }
                    }
                    DemoNotice()
                } else {
                    EmptyMessage(symbol: "lock", title: "This task isn’t shared here", message: "Return to the plan or switch to a role with access in Circle.")
                }
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Task details").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let task, store.state.canCoordinate, task.status == .needsHelp || task.status == .claimed {
                    Button("Edit") { editing = true }
                }
            }
            .sheet(isPresented: $editing) { if let task { TaskEditor(existing: task) } }
            .confirmationDialog("Cancel this demo arrangement?", isPresented: $confirmingCancel, titleVisibility: .visible) {
                Button("Cancel arrangement & release payment", role: .destructive) { store.change { try $0.cancelArrangement(taskID) } }
            } message: { Text("The task will need help again. Its simulated payment will be released back to your demo budget.") }
    }
}

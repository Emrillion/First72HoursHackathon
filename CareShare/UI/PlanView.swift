import SwiftUI

struct PlanView: View {
    @EnvironmentObject var store: AppStore
    @State private var filter = "All"
    @State private var adding = false
    private let filters = ["All", "Needs help", "Covered", "Done"]
    private var tasks: [CareTask] {
        store.state.visibleTasks().filter {
            switch filter {
            case "Needs help": return $0.status == .needsHelp
            case "Covered": return $0.status == .claimed || $0.status == .arranged
            case "Done": return $0.status == .completed
            default: return true
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let plan = store.state.plan {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Image("BrandSymbol").resizable().scaledToFit().frame(width: 40, height: 40).accessibilityHidden(true)
                            Text("YOUR RECOVERY, TOGETHER").font(.caption.weight(.bold)).tracking(1)
                        }
                        Text("A little help for\n\(plan.patientName).")
                            .font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                        Text("The first 72 hours").font(.headline)
                        Text("\(plan.discharge.careDate) – \(plan.windowEnd.careDate)")
                            .font(.subheadline).foregroundStyle(CareTheme.muted)
                        let all = store.state.visibleTasks()
                        let done = all.filter { $0.status == .completed }.count
                        ProgressView(value: Double(done), total: Double(max(1, all.count)))
                            .accessibilityLabel("\(done) of \(all.count) tasks completed")
                        Text("\(all.filter { $0.status == .needsHelp }.count) need help · \(done) of \(all.count) complete")
                            .font(.subheadline.weight(.semibold))
                        if Date() > plan.windowEnd {
                            Text("The 72-hour window has ended. Your remaining needs stay here.").font(.callout)
                        }
                    }.padding(24).frame(maxWidth: .infinity, alignment: .leading)
                        .background(CareTheme.mint).clipShape(RoundedRectangle(cornerRadius: 28))
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("Your plan").font(.title2.bold())
                    Spacer()
                    if store.state.canCoordinate {
                        Button { adding = true } label: { Label("Add task", systemImage: "plus") }.frame(minHeight: 44)
                            .accessibilityIdentifier("addTask")
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { item in
                            Button { filter = item } label: {
                                Text(item).font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 16).frame(minHeight: 44)
                                    .background(filter == item ? CareTheme.teal : .white)
                                    .foregroundStyle(filter == item ? .white : CareTheme.ink).clipShape(Capsule())
                            }.accessibilityAddTraits(filter == item ? [.isSelected] : [])
                        }
                    }
                }
                if tasks.isEmpty {
                    EmptyMessage(symbol: "leaf", title: "A little breathing room",
                                 message: filter == "All" ? "Add the everyday things you’d like a hand with." : "No tasks in this view. Your other needs are under All.")
                }
                ForEach(tasks) { task in
                    NavigationLink { TaskDetailView(taskID: task.id) } label: { TaskCard(task: task) }
                        .buttonStyle(.plain).accessibilityIdentifier("task-\(task.title)")
                }
                Text("Viewing as \(store.state.activeMember?.name ?? "") · change demo role in Circle")
                    .font(.footnote).foregroundStyle(CareTheme.muted)
                DemoNotice()
            }.padding(16)
        }.background(CareTheme.cloud)
            .navigationTitle("CareShare").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $adding) { TaskEditor() }
    }
}

struct TaskCard: View {
    @EnvironmentObject var store: AppStore
    let task: CareTask
    var body: some View {
        CareCard {
            HStack(alignment: .top) {
                Image(systemName: task.category.symbol).font(.title2)
                    .frame(width: 46, height: 46).background(CareTheme.cloud).clipShape(RoundedRectangle(cornerRadius: 14)).accessibilityHidden(true)
                Spacer()
                StatusBadge(status: task.status)
            }
            Text(task.title).font(.title3.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
            Label(task.due.careDate, systemImage: "clock").font(.subheadline).foregroundStyle(CareTheme.muted)
            if task.isOverdue(at: Date()) { Label("Overdue · still needs follow-through", systemImage: "exclamationmark.circle").font(.subheadline).foregroundStyle(CareTheme.amber) }
            if task.isPriority { Label("Priority", systemImage: "flag").font(.caption.weight(.semibold)) }
            Divider()
            HStack(alignment: .top) {
                Text(task.status == .needsHelp ? "A little help needed" : store.state.ownerName(for: task))
                    .font(.subheadline).foregroundStyle(CareTheme.muted)
                Spacer()
                Image(systemName: "arrow.up.right").accessibilityHidden(true)
            }
        }.accessibilityElement(children: .combine)
    }
}

struct TaskEditor: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    var existing: CareTask?
    @State private var title = ""
    @State private var category: TaskCategory = .meals
    @State private var due = Date().addingTimeInterval(3600)
    @State private var priority = false
    @State private var notes = ""
    @State private var visibility: TaskVisibility = .circle

    var body: some View {
        NavigationStack {
            Form {
                if existing == nil {
                    Section("Start with an everyday need") {
                        Button("A prepared meal") { title = "A prepared meal"; category = .meals }
                        Button("A ride to an appointment") { title = "A ride to an appointment"; category = .transportation }
                        Button("Help around the house") { title = "Help around the house"; category = .household }
                    }
                }
                Section("Task details") {
                    TextField("What would help?", text: $title).accessibilityIdentifier("taskTitle")
                    Picker("Category", selection: $category) { ForEach(TaskCategory.allCases) { Text($0.rawValue).tag($0) } }
                    DatePicker("Needed by", selection: $due)
                    Toggle("Priority", isOn: $priority)
                    TextField("Notes (optional)", text: $notes, axis: .vertical).lineLimit(3...6)
                    Picker("Share with", selection: $visibility) {
                        ForEach(TaskVisibility.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                }
                Section {
                    Text("No one is assigned until they accept responsibility. Share only practical details needed for this task.").font(.callout)
                    if let plan = store.state.plan, due > plan.windowEnd || due < plan.discharge {
                        Text("This task falls outside the first 72 hours. It will still appear in your plan.").font(.callout).foregroundStyle(CareTheme.amber)
                    }
                }
            }.navigationTitle(existing == nil ? "Add a task" : "Edit task").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save task") {
                            guard let plan = store.state.plan else { return }
                            var task = existing ?? CareTask(planID: plan.id, title: title, category: category, due: due)
                            task.title = title; task.category = category; task.due = due
                            task.isPriority = priority; task.notes = notes; task.visibility = visibility
                            if store.change({ try $0.saveTask(task) }) { dismiss() }
                        }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityIdentifier("saveTask")
                    }
                }
                .onAppear {
                    if let task = existing {
                        title = task.title; category = task.category; due = task.due
                        priority = task.isPriority; notes = task.notes; visibility = task.visibility
                    }
                }
        }
    }
}

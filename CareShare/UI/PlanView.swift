import SwiftUI

struct PlanView: View {
    @EnvironmentObject var store: AppStore
    @State private var filter = "To do"
    @State private var adding = false
    private let filters = ["To do", "Needs help", "Done", "All"]
    private var tasks: [CareTask] {
        store.state.visibleTasks().filter {
            switch filter {
            case "Needs help": return $0.status == .needsHelp
            case "To do": return $0.status != .completed
            case "Done": return $0.status == .completed
            default: return true
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let plan = store.state.plan {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(plan.patientName)’s care plan").font(.title.bold())
                        Text("One thing at a time. Your next steps are below.")
                            .font(.subheadline).foregroundStyle(CareTheme.muted)
                        let all = store.state.visibleTasks()
                        let done = all.filter { $0.status == .completed }.count
                        ProgressView(value: Double(done), total: Double(max(1, all.count)))
                            .accessibilityLabel("\(done) of \(all.count) tasks completed")
                        Text("\(all.filter { $0.status == .needsHelp }.count) need help · \(done) of \(all.count) done")
                            .font(.subheadline.weight(.semibold))
                        DisclosureGroup("First 72 hours") {
                            Text("\(plan.discharge.careDate) – \(plan.windowEnd.careDate)")
                                .font(.footnote).frame(maxWidth: .infinity, alignment: .leading)
                        }.font(.subheadline)
                        if Date() > plan.windowEnd {
                            Text("Your remaining needs stay here after the first 72 hours.").font(.callout)
                        }
                    }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                        .background(CareTheme.mint).clipShape(RoundedRectangle(cornerRadius: 24))
                }
                HStack(alignment: .firstTextBaseline) {
                    Text(filter == "Done" ? "Completed" : "Your tasks").font(.title2.bold())
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
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: task.category.symbol).font(.title3)
                    .frame(width: 40, height: 40).background(CareTheme.cloud)
                    .clipShape(RoundedRectangle(cornerRadius: 12)).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title).font(.headline).fixedSize(horizontal: false, vertical: true)
                    Text(task.due.careDate).font(.subheadline).foregroundStyle(CareTheme.muted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption).padding(.top, 6).accessibilityHidden(true)
            }
            StatusBadge(status: task.status)
            if task.status != .needsHelp {
                Text(store.state.ownerName(for: task)).font(.subheadline).foregroundStyle(CareTheme.muted)
            }
            if task.isOverdue(at: Date()) {
                Label("Overdue", systemImage: "exclamationmark.circle").font(.subheadline).foregroundStyle(CareTheme.amber)
            } else if task.isPriority {
                Label("Priority", systemImage: "flag").font(.caption.weight(.semibold))
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
                    DisclosureGroup("More options") {
                        Toggle("Priority", isOn: $priority)
                        TextField("Notes (optional)", text: $notes, axis: .vertical).lineLimit(3...6)
                        Picker("Share with", selection: $visibility) {
                            ForEach(TaskVisibility.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
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

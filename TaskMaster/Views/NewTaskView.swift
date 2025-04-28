import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date()
    @State private var priority: TaskTask.Priority = .medium
    @State private var category: TaskTask.Category = .personal
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case title, description
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Task Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                    
                    TextField("Description", text: $taskDescription, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .submitLabel(.done)
                        .lineLimit(3...6)
                }
                
                Section {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskTask.Priority.allCases, id: \.self) { priority in
                            Label(priority.rawValue, systemImage: "flag.fill")
                                .foregroundColor(priorityColor(for: priority))
                                .tag(priority)
                        }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(TaskTask.Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onSubmit {
                switch focusedField {
                case .title:
                    focusedField = .description
                case .description:
                    focusedField = nil
                case .none:
                    break
                }
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
    
    private func addTask() {
        let task = TaskTask(
            title: title,
            description: taskDescription,
            dueDate: dueDate,
            priority: priority,
            category: category
        )
        viewModel.addTask(task)
        dismiss()
    }
    
    private func priorityColor(for priority: TaskTask.Priority) -> Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}
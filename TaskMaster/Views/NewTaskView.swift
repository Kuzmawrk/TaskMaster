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
                    
                    // Priority Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Priority")
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskTask.Priority.allCases, id: \.self) { priorityOption in
                                PriorityButton(
                                    priority: priorityOption,
                                    isSelected: priority == priorityOption,
                                    action: { priority = priorityOption }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Category")
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(TaskTask.Category.allCases, id: \.self) { categoryOption in
                                    CategoryButton(
                                        category: categoryOption,
                                        isSelected: category == categoryOption,
                                        action: { category = categoryOption }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
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
        clearFields()
        dismiss()
    }
    
    private func clearFields() {
        title = ""
        taskDescription = ""
        dueDate = Date()
        priority = .medium
        category = .personal
        focusedField = nil
    }
}
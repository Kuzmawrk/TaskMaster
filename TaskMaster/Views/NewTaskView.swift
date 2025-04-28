import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date()
    @State private var priority: TaskTask.Priority = .medium
    @State private var category: TaskTask.Category = .personal
    @State private var showingPriorityPicker = false
    @State private var showingCategoryPicker = false
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
                    
                    Button(action: { showingPriorityPicker = true }) {
                        HStack {
                            Text("Priority")
                            Spacer()
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(priorityColor(for: priority))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: { showingCategoryPicker = true }) {
                        HStack {
                            Text("Category")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                                    .foregroundColor(.secondary)
                            }
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
            .sheet(isPresented: $showingPriorityPicker) {
                PriorityPickerView(selectedPriority: $priority)
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $category)
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
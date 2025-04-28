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

struct PriorityButton: View {
    let priority: TaskTask.Priority
    let isSelected: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 12, height: 12)
                
                Text(priority.rawValue)
                    .font(.system(size: 15))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryButton: View {
    let category: TaskTask.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(category.rawValue)
                    .font(.system(size: 15))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
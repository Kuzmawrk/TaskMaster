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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title & Description
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Task Title", text: $title)
                            .font(.title2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .title)
                            .submitLabel(.next)
                        
                        TextField("Description", text: $taskDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .description)
                            .submitLabel(.done)
                    }
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $dueDate)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    
                    // Priority Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Priority")
                            .font(.subheadline)
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
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Category")
                            .font(.subheadline)
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
                    
                    Spacer(minLength: 20)
                    
                    // Add Button
                    Button {
                        addTask()
                    } label: {
                        Text("Add Task")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(title.isEmpty)
                    .buttonStyle(CustomButtonStyle())
                }
                .padding()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(CustomButtonStyle())
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
import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    let task: TaskTask
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 16) {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 12, height: 12)
                    
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                    
                    Spacer()
                }
                
                // Category
                Label(task.category.rawValue, systemImage: task.category.icon)
                    .foregroundColor(.secondary)
                
                // Due Date
                VStack(alignment: .leading, spacing: 4) {
                    Text("Due Date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(task.dueDate.formatted(date: .long, time: .shortened))
                        .font(.body)
                        .foregroundColor(isOverdue ? .red : .primary)
                }
                
                // Description
                if !task.description.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(task.description)
                            .font(.body)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        withAnimation {
                            viewModel.toggleTaskCompletion(task)
                        }
                    } label: {
                        Label(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                              systemImage: task.isCompleted ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(task.isCompleted ? .red : .green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(task.isCompleted ? .red : .green, lineWidth: 2)
                            )
                    }
                    
                    HStack(spacing: 16) {
                        // Edit Button
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // Share Button
                        Button {
                            shareTask()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                    // Delete Button
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Task", systemImage: "trash.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditTaskView(viewModel: viewModel, task: task)
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private var isOverdue: Bool {
        !task.isCompleted && task.dueDate < Date()
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
    
    private func deleteTask() {
        withAnimation {
            viewModel.deleteTask(task)
            dismiss()
        }
    }
    
    private func shareTask() {
        let taskText = """
        Task: \(task.title)
        Due: \(task.dueDate.formatted(date: .long, time: .shortened))
        Priority: \(task.priority.rawValue)
        Category: \(task.category.rawValue)
        \(task.description)
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [taskText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedDueDate: Date
    @State private var editedPriority: TaskTask.Priority
    @State private var editedCategory: TaskTask.Category
    @State private var showingPriorityPicker = false
    @State private var showingCategoryPicker = false
    @FocusState private var focusedField: Field?
    
    let task: TaskTask
    
    private enum Field {
        case title, description
    }
    
    init(viewModel: TaskViewModel, task: TaskTask) {
        self.viewModel = viewModel
        self.task = task
        _editedTitle = State(initialValue: task.title)
        _editedDescription = State(initialValue: task.description)
        _editedDueDate = State(initialValue: task.dueDate)
        _editedPriority = State(initialValue: task.priority)
        _editedCategory = State(initialValue: task.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Task Title", text: $editedTitle)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                    
                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .submitLabel(.done)
                        .lineLimit(3...6)
                }
                
                Section {
                    DatePicker("Due Date", selection: $editedDueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Button(action: { showingPriorityPicker = true }) {
                        HStack {
                            Text("Priority")
                            Spacer()
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(priorityColor(for: editedPriority))
                                    .frame(width: 12, height: 12)
                                Text(editedPriority.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: { showingCategoryPicker = true }) {
                        HStack {
                            Text("Category")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: editedCategory.icon)
                                Text(editedCategory.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedTitle.isEmpty)
                }
            }
            .sheet(isPresented: $showingPriorityPicker) {
                PriorityPickerView(selectedPriority: $editedPriority)
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $editedCategory)
            }
        }
    }
    
    private func saveChanges() {
        let updatedTask = TaskTask(
            id: task.id,
            title: editedTitle,
            description: editedDescription,
            dueDate: editedDueDate,
            isCompleted: task.isCompleted,
            priority: editedPriority,
            category: editedCategory
        )
        viewModel.updateTask(updatedTask)
        dismiss()
    }
    
    private func priorityColor(for priority: TaskTask.Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}
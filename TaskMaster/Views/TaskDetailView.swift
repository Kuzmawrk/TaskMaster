import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingDeleteAlert = false
    
    let task: TaskTask
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 16) {
                    Circle()
                        .fill(priorityColor(for: task.priority))
                        .frame(width: 12, height: 12)
                    
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                    
                    Spacer()
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
                                isSelected: task.priority == priorityOption,
                                action: {
                                    updatePriority(to: priorityOption)
                                }
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
                                    isSelected: task.category == categoryOption,
                                    action: {
                                        updateCategory(to: categoryOption)
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Due Date
                VStack(alignment: .leading, spacing: 4) {
                    Text("Due Date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: Binding(
                        get: { task.dueDate },
                        set: { updateDueDate(to: $0) }
                    ))
                    .datePickerStyle(.compact)
                    .labelsHidden()
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
                    .buttonStyle(CustomButtonStyle())
                    
                    HStack(spacing: 16) {
                        // Share Button
                        Button {
                            shareTask()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(CustomButtonStyle())
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
                    .buttonStyle(CustomButtonStyle())
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
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
    
    private func priorityColor(for priority: TaskTask.Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
    
    private func updateTask(
        title: String? = nil,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: TaskTask.Priority? = nil,
        category: TaskTask.Category? = nil
    ) {
        let updatedTask = TaskTask(
            id: task.id,
            title: title ?? task.title,
            description: description ?? task.description,
            dueDate: dueDate ?? task.dueDate,
            isCompleted: task.isCompleted,
            priority: priority ?? task.priority,
            category: category ?? task.category
        )
        viewModel.updateTask(updatedTask)
    }
    
    private func updatePriority(to newPriority: TaskTask.Priority) {
        updateTask(priority: newPriority)
    }
    
    private func updateCategory(to newCategory: TaskTask.Category) {
        updateTask(category: newCategory)
    }
    
    private func updateDueDate(to newDate: Date) {
        updateTask(dueDate: newDate)
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
import SwiftUI

struct TaskRow: View {
    let task: TaskTask
    let onToggle: () -> Void
    
    private var isOverdue: Bool {
        !task.isCompleted && task.dueDate < Date()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color.green : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                    
                    if task.reminderEnabled {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 8) {
                    Label(task.category.rawValue, systemImage: task.category.icon)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(task.dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(isOverdue ? .red : .gray)
                }
            }
            
            Spacer()
            
            // Priority indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .contentShape(Rectangle())
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}
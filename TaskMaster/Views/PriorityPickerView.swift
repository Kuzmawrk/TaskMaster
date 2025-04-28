import SwiftUI

struct PriorityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPriority: TaskTask.Priority
    
    var body: some View {
        NavigationView {
            List(TaskTask.Priority.allCases, id: \.self) { priority in
                Button {
                    selectedPriority = priority
                    dismiss()
                } label: {
                    HStack {
                        Label {
                            Text(priority.rawValue)
                        } icon: {
                            Circle()
                                .fill(priorityColor(for: priority))
                                .frame(width: 12, height: 12)
                        }
                        
                        Spacer()
                        
                        if priority == selectedPriority {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Priority")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
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
import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: TaskTask.Category
    
    var body: some View {
        NavigationView {
            List(TaskTask.Category.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                    dismiss()
                } label: {
                    HStack {
                        Label {
                            Text(category.rawValue)
                        } icon: {
                            Image(systemName: category.icon)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Category")
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
}
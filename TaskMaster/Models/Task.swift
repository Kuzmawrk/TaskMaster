import Foundation

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date
    var isCompleted: Bool
    var priority: Priority
    var category: Category
    var reminderEnabled: Bool
    
    init(id: UUID = UUID(), 
         title: String = "",
         description: String = "",
         dueDate: Date = Date(),
         isCompleted: Bool = false,
         priority: Priority = .medium,
         category: Category = .personal,
         reminderEnabled: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.reminderEnabled = reminderEnabled
    }
}

// MARK: - Task Enums
extension Task {
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: String {
            switch self {
            case .low: return "priorityLow"
            case .medium: return "priorityMedium"
            case .high: return "priorityHigh"
            }
        }
    }
    
    enum Category: String, Codable, CaseIterable {
        case personal = "Personal"
        case work = "Work"
        case shopping = "Shopping"
        case health = "Health"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .work: return "briefcase.fill"
            case .shopping: return "cart.fill"
            case .health: return "heart.fill"
            case .other: return "square.fill"
            }
        }
    }
}
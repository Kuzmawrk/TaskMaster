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
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case dueDate
        case isCompleted
        case priority
        case category
        case reminderEnabled
    }
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        priority = try container.decode(Priority.self, forKey: .priority)
        category = try container.decode(Category.self, forKey: .category)
        reminderEnabled = try container.decode(Bool.self, forKey: .reminderEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(priority, forKey: .priority)
        try container.encode(category, forKey: .category)
        try container.encode(reminderEnabled, forKey: .reminderEnabled)
    }
    
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
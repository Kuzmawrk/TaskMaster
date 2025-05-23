import Foundation
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskTask] = []
    @Published var showingNewTaskSheet = false
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedTabIndex = 0
    
    private let tasksKey = "savedTasks"
    
    enum TaskFilter {
        case all, today, upcoming, completed
        
        var title: String {
            switch self {
            case .all: return "All Tasks"
            case .today: return "Today"
            case .upcoming: return "Upcoming"
            case .completed: return "Completed"
            }
        }
    }
    
    init() {
        loadTasks()
    }
    
    func addTask(_ task: TaskTask) {
        tasks.append(task)
        saveTasks()
        NotificationCenter.default.post(
            name: .taskNotification,
            object: nil,
            userInfo: ["type": ToastType.added.rawValue]
        )
        selectedTabIndex = 0
    }
    
    func deleteTask(_ task: TaskTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        NotificationCenter.default.post(
            name: .taskNotification,
            object: nil,
            userInfo: ["type": ToastType.deleted.rawValue]
        )
    }
    
    func toggleTaskCompletion(_ task: TaskTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
            NotificationCenter.default.post(
                name: .taskNotification,
                object: nil,
                userInfo: [
                    "type": ToastType.statusChanged.rawValue,
                    "completed": tasks[index].isCompleted
                ]
            )
        }
    }
    
    func updateTask(_ task: TaskTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
            NotificationCenter.default.post(
                name: .taskNotification,
                object: nil,
                userInfo: ["type": ToastType.updated.rawValue]
            )
        }
    }
    
    func filteredTasks(_ filter: TaskFilter = .all) -> [TaskTask] {
        switch filter {
        case .all:
            return tasks.sorted { $0.dueDate < $1.dueDate }
        case .today:
            return tasks.filter { Calendar.current.isDateInToday($0.dueDate) }
                .sorted { $0.dueDate < $1.dueDate }
        case .upcoming:
            return tasks.filter { $0.dueDate > Date() && !$0.isCompleted }
                .sorted { $0.dueDate < $1.dueDate }
        case .completed:
            return tasks.filter { $0.isCompleted }
                .sorted { $0.dueDate < $1.dueDate }
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([TaskTask].self, from: data) {
            tasks = decoded
        }
    }
}

enum ToastType: String {
    case added
    case deleted
    case updated
    case statusChanged
    
    var message: String {
        switch self {
        case .added:
            return "Task Added Successfully"
        case .deleted:
            return "Task Deleted"
        case .updated:
            return "Task Updated"
        case .statusChanged:
            return "" // Will be set dynamically
        }
    }
    
    var icon: String {
        switch self {
        case .added:
            return "checkmark.circle.fill"
        case .deleted:
            return "trash.fill"
        case .updated:
            return "pencil.circle.fill"
        case .statusChanged:
            return "circle.inset.filled"
        }
    }
    
    var color: Color {
        switch self {
        case .added:
            return .green
        case .deleted:
            return .red
        case .updated:
            return .blue
        case .statusChanged:
            return .green
        }
    }
}

extension Notification.Name {
    static let taskNotification = Notification.Name("taskNotification")
}
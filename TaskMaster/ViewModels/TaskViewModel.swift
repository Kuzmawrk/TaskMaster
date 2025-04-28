import Foundation
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var showingNewTaskSheet = false
    @Published var selectedFilter: TaskFilter = .all
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "savedTasks"
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
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
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func filteredTasks(_ filter: TaskFilter = .all) -> [Task] {
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
        do {
            let data = try jsonEncoder.encode(tasks)
            userDefaults.set(data, forKey: tasksKey)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }
    
    private func loadTasks() {
        guard let data = userDefaults.data(forKey: tasksKey) else { return }
        
        do {
            tasks = try jsonDecoder.decode([Task].self, from: data)
        } catch {
            print("Error loading tasks: \(error)")
            tasks = []
        }
    }
}
import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    private var displayedTasks: [TaskTask] {
        viewModel.filteredTasks(viewModel.selectedFilter)
    }
    
    private var totalTasks: Int {
        displayedTasks.count
    }
    
    private var completedTasks: Int {
        displayedTasks.filter { $0.isCompleted }.count
    }
    
    private var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    private var priorityDistribution: [(priority: TaskTask.Priority, count: Int)] {
        TaskTask.Priority.allCases.map { priority in
            (priority, displayedTasks.filter { $0.priority == priority }.count)
        }
    }
    
    private var categoryDistribution: [(category: TaskTask.Category, count: Int)] {
        TaskTask.Category.allCases.map { category in
            (category, displayedTasks.filter { $0.category == category }.count)
        }
    }
    
    private var overdueTasks: Int {
        let now = Date()
        return displayedTasks.filter { !$0.isCompleted && $0.dueDate < now }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Filter
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundColor(.blue)
                        Text("Showing statistics for: \(viewModel.selectedFilter.title)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Summary Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Total Tasks",
                            value: "\(totalTasks)",
                            icon: "list.bullet.circle.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(completedTasks)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Overdue Tasks
                    if overdueTasks > 0 {
                        StatCard(
                            title: "Overdue Tasks",
                            value: "\(overdueTasks)",
                            icon: "exclamationmark.circle.fill",
                            color: .red
                        )
                        .padding(.horizontal)
                    }
                    
                    // Priority Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Priority Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(priorityDistribution, id: \.priority) { item in
                                PriorityProgressBar(
                                    priority: item.priority,
                                    count: item.count,
                                    total: totalTasks
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                    }
                    .padding(.horizontal)
                    
                    // Category Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Category Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(categoryDistribution, id: \.category) { item in
                                CategoryRow(
                                    category: item.category,
                                    count: item.count,
                                    total: totalTasks
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                    }
                    .padding(.horizontal)
                    
                    // Completion Rate
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Completion Rate")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            CompletionRateRing(
                                progress: completionRate
                            )
                            .frame(width: 150, height: 150)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                CompletionStatRow(
                                    title: "Completed",
                                    count: completedTasks,
                                    color: .green
                                )
                                CompletionStatRow(
                                    title: "In Progress",
                                    count: totalTasks - completedTasks,
                                    color: .orange
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// Оставляем все вспомогательные View без изменений
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct PriorityProgressBar: View {
    let priority: TaskTask.Priority
    let count: Int
    let total: Int
    
    private var progress: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(priority.rawValue)
                Spacer()
                Text("\(count)")
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    Rectangle()
                        .fill(priorityColor)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
}

struct CategoryRow: View {
    let category: TaskTask.Category
    let count: Int
    let total: Int
    
    private var percentage: Int {
        total > 0 ? Int((Double(count) / Double(total)) * 100) : 0
    }
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.blue)
            
            Text(category.rawValue)
            
            Spacer()
            
            Text("\(count) (\(percentage)%)")
                .foregroundColor(.secondary)
        }
    }
}

struct CompletionRateRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CompletionStatRow: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
            
            Spacer()
            
            Text("\(count)")
                .foregroundColor(.secondary)
        }
    }
}
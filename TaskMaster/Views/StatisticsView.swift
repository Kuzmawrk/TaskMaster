import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Total Tasks",
                            value: "\(viewModel.tasks.count)",
                            icon: "list.bullet.circle.fill",
                            color: Color.accentColor
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(viewModel.tasks.filter { $0.isCompleted }.count)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Overdue Tasks
                    let overdueTasks = viewModel.tasks.filter { !$0.isCompleted && $0.dueDate < Date() }.count
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
                            ForEach(TaskTask.Priority.allCases, id: \.self) { priority in
                                let count = viewModel.tasks.filter { $0.priority == priority }.count
                                PriorityProgressBar(
                                    priority: priority,
                                    count: count,
                                    total: viewModel.tasks.count
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
                            ForEach(TaskTask.Category.allCases, id: \.self) { category in
                                let count = viewModel.tasks.filter { $0.category == category }.count
                                CategoryRow(
                                    category: category,
                                    count: count,
                                    total: viewModel.tasks.count
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
                        
                        let completedCount = viewModel.tasks.filter { $0.isCompleted }.count
                        let progress = viewModel.tasks.isEmpty ? 0.0 : Double(completedCount) / Double(viewModel.tasks.count)
                        
                        HStack {
                            CompletionRateRing(
                                progress: progress
                            )
                            .frame(width: 150, height: 150)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                CompletionStatRow(
                                    title: "Completed",
                                    count: completedCount,
                                    color: .green
                                )
                                CompletionStatRow(
                                    title: "In Progress",
                                    count: viewModel.tasks.count - completedCount,
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
                .foregroundColor(Color.accentColor)
            
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
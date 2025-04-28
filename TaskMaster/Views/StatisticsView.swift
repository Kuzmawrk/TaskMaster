import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
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
                    // Filter selector
                    Picker("Filter", selection: $viewModel.selectedFilter) {
                        ForEach([TaskViewModel.TaskFilter.all,
                                .today,
                                .upcoming,
                                .completed], id: \.self) { filter in
                            Text(filter.title)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
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
                    .id(viewModel.statisticsNeedsUpdate) // Force view update
                    
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
                    .id(viewModel.statisticsNeedsUpdate) // Force view update
                    
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
                    .id(viewModel.statisticsNeedsUpdate) // Force view update
                    
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
                    .id(viewModel.statisticsNeedsUpdate) // Force view update
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .background(Color(.systemGroupedBackground))
        }
    }
}
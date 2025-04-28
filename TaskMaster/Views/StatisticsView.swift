import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time frame selector
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue)
                                .tag(timeFrame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Summary Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Total Tasks",
                            value: "\(viewModel.totalTasksCount)",
                            icon: "list.bullet.circle.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(viewModel.completedTasksCount)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Priority Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Priority Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(TaskTask.Priority.allCases, id: \.self) { priority in
                                PriorityProgressBar(
                                    priority: priority,
                                    count: viewModel.taskCount(for: priority),
                                    total: viewModel.totalTasksCount
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
                                CategoryRow(
                                    category: category,
                                    count: viewModel.taskCount(for: category),
                                    total: viewModel.totalTasksCount
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
                                progress: Double(viewModel.completedTasksCount) / Double(max(1, viewModel.totalTasksCount))
                            )
                            .frame(width: 150, height: 150)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                CompletionStatRow(
                                    title: "Completed",
                                    count: viewModel.completedTasksCount,
                                    color: .green
                                )
                                CompletionStatRow(
                                    title: "In Progress",
                                    count: viewModel.totalTasksCount - viewModel.completedTasksCount,
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
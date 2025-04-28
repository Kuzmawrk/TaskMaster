import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("TaskMaster")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingNewTaskSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewTaskSheet) {
                NewTaskView(viewModel: viewModel)
            }
        }
    }
    
    private var taskList: some View {
        ScrollView {
            VStack(spacing: 12) {
                filterSegment
                
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredTasks(viewModel.selectedFilter)) { task in
                        TaskRow(task: task) {
                            withAnimation {
                                viewModel.toggleTaskCompletion(task)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteTask(task)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var filterSegment: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([TaskViewModel.TaskFilter.all,
                        .today,
                        .upcoming,
                        .completed], id: \.self) { filter in
                    filterButton(for: filter)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func filterButton(for filter: TaskViewModel.TaskFilter) -> some View {
        Button {
            withAnimation {
                viewModel.selectedFilter = filter
            }
        } label: {
            Text(filter.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(viewModel.selectedFilter == filter ?
                              Color.blue : Color(.systemGray6))
                )
                .foregroundColor(viewModel.selectedFilter == filter ?
                               .white : .primary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add your first task by tapping the + button")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                viewModel.showingNewTaskSheet = true
            } label: {
                Text("Add Task")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
        }
    }
}
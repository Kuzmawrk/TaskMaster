import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTab = 0
    @State private var showingTaskAddedToast = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TaskListView()
                    .tabItem {
                        Label("Tasks", systemImage: "checklist")
                    }
                    .tag(0)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(1)
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            
            // Task Added Toast
            if showingTaskAddedToast {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Task Added Successfully")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.95))
                    .cornerRadius(20)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskAdded)) { _ in
            showTaskAddedToast()
        }
    }
    
    private func showTaskAddedToast() {
        withAnimation {
            showingTaskAddedToast = true
        }
        selectedTab = 0 // Switch to Tasks tab
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingTaskAddedToast = false
            }
        }
    }
}

#Preview {
    ContentView()
}
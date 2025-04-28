import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted = false
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedTab = 0
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastIcon = ""
    @State private var toastColor: Color = .green
    
    var body: some View {
        ZStack {
            if !isOnboardingCompleted {
                OnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
                    .transition(.opacity.combined(with: .slide))
            } else {
                TabView(selection: $selectedTab) {
                    TaskListView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("Tasks", systemImage: "checklist")
                        }
                        .tag(0)
                    
                    StatisticsView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("Statistics", systemImage: "chart.bar.fill")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(2)
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
                
                // Toast
                if showingToast {
                    VStack {
                        Spacer()
                        ToastView(
                            message: toastMessage,
                            icon: toastIcon,
                            color: toastColor
                        )
                        .padding(.bottom, 90)
                        .padding(.horizontal)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isOnboardingCompleted)
        .onReceive(NotificationCenter.default.publisher(for: .taskNotification)) { notification in
            handleTaskNotification(notification)
        }
    }
    
    private func handleTaskNotification(_ notification: Notification) {
        guard let typeString = notification.userInfo?["type"] as? String,
              let type = ToastType(rawValue: typeString) else { return }
        
        toastIcon = type.icon
        toastColor = type.color
        
        if type == .statusChanged {
            if let completed = notification.userInfo?["completed"] as? Bool {
                toastMessage = completed ? "Task Completed" : "Task Marked as Incomplete"
            }
        } else {
            toastMessage = type.message
        }
        
        showToast()
    }
    
    private func showToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showingToast = false
            }
        }
    }
}
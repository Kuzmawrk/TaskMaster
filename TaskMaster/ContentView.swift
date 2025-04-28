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
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(1)
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
                        .padding([.leading, .trailing], 16)
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

struct ToastView: View {
    let message: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(message)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer(minLength: 10)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
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
                    ToastView(message: "Task Added Successfully")
                        .padding(.bottom, 90) // Above tab bar
                        .padding(.horizontal)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1) // Ensure toast is above all content
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskAdded)) { _ in
            showTaskAddedToast()
        }
    }
    
    private func showTaskAddedToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingTaskAddedToast = true
        }
        selectedTab = 0 // Switch to Tasks tab
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showingTaskAddedToast = false
            }
        }
    }
}

struct ToastView: View {
    let message: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.green)
            
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
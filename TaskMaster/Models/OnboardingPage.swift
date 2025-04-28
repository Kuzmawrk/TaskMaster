import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
    
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "checklist.checked",
            title: "Manage Your Tasks",
            description: "Create and organize your daily tasks with priority levels and categories. Stay on top of your responsibilities with our intuitive task management system."
        ),
        OnboardingPage(
            image: "calendar.badge.clock",
            title: "Track Due Dates",
            description: "Set due dates for your tasks and never miss a deadline. Filter tasks by today, upcoming, or completed to focus on what matters most."
        ),
        OnboardingPage(
            image: "square.and.arrow.up.circle",
            title: "Share & Collaborate",
            description: "Share your tasks with others and keep everyone in sync. Edit, mark as complete, or update task details with just a few taps."
        )
    ]
}
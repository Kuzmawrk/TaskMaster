import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Terms of Use")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                    
                    Text("Welcome to TaskMaster! By using our app, you agree to these terms of use. Please read them carefully.")
                        .fontWeight(.medium)
                    
                    Text("1. Acceptance of Terms")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("By accessing or using TaskMaster, you agree to be bound by these Terms of Use and all applicable laws and regulations.")
                    
                    Text("2. User Responsibilities")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You are responsible for:\n• Maintaining the confidentiality of your account\n• All activities that occur under your account\n• Ensuring your data is accurate and up-to-date")
                }
                
                Group {
                    Text("3. Intellectual Property")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("TaskMaster and its original content, features, and functionality are owned by us and are protected by international copyright, trademark, and other intellectual property laws.")
                    
                    Text("4. Prohibited Activities")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You agree not to:\n• Use the app for any illegal purpose\n• Attempt to gain unauthorized access\n• Interfere with the app's security features")
                    
                    Text("5. Termination")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We may terminate or suspend your access to the app immediately, without prior notice, for any reason whatsoever.")
                    
                    Text("6. Changes to Terms")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We reserve the right to modify or replace these Terms at any time. Your continued use of the app after any changes constitutes acceptance of those changes.")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }
}
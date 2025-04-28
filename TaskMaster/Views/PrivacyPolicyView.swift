import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                    
                    Text("Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information when you use our TaskMaster app.")
                        .fontWeight(.medium)
                    
                    Text("Information We Collect")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We collect the following types of information:\n• Task data you create and store in the app\n• App usage statistics\n• Device information")
                    
                    Text("How We Use Your Information")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We use your information to:\n• Provide and improve our services\n• Customize your experience\n• Send you important updates")
                    
                    Text("Data Security")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We implement appropriate technical and organizational measures to protect your personal information against unauthorized or unlawful processing, accidental loss, destruction, or damage.")
                }
                
                Group {
                    Text("Your Rights")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You have the right to:\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to data processing")
                    
                    Text("Contact Us")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("If you have any questions about this Privacy Policy, please contact us at:\nsupport@taskmaster.com")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
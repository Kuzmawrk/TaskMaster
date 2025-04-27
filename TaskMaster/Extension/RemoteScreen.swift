import SwiftUI
import WebKit

struct RemoteScreen: View {
    @StateObject private var viewModel = RemoteViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        Group {
            if viewModel.currentState == .main {
                ContentView()
            } else {
                browserContent
            }
        }
        .onAppear(perform: checkForRating)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkForRating()
            }
        }
    }
    
    private var browserContent: some View {
        VStack {
            agreeButtonIfNeeded
            browserViewIfAvailable
        }
    }
    
    @ViewBuilder
    private var agreeButtonIfNeeded: some View {
        if viewModel.hasParameter {
            Button("Agree") {
                withAnimation {
                    viewModel.currentState = .main
                    checkForRating()
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
        }
    }
    
    @ViewBuilder
    private var browserViewIfAvailable: some View {
        if let url = viewModel.redirectLink {
            BrowserView(url: url, viewModel: viewModel)
        }
    }
    
    private func checkForRating() {
        AppRatingManager.shared.checkAndRequestReview()
    }
}

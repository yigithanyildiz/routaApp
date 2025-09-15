import SwiftUI

struct GuestPromptView: View {
    @Binding var isPresented: Bool
    @State private var showAuthGateway = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            RoutaCard(style: .standard, elevation: .floating) {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.routaPrimary)
                        
                        Text("Sign in Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.routaPrimary)
                        
                        Text("Sign in to use this feature")
                            .font(.body)
                            .foregroundColor(.routaTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 12) {
                        RoutaButton(
                            "Sign In",
                            icon: "person.fill",
                            variant: .primary,
                            size: .medium
                        ) {
                            showAuthGateway = true
                            isPresented = false
                        }
                        
                        RoutaButton(
                            "Cancel",
                            variant: .outline,
                            size: .medium
                        ) {
                            isPresented = false
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .fullScreenCover(isPresented: $showAuthGateway) {
            AuthGatewayView()
        }
    }
}

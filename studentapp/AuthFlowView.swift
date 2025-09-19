import SwiftUI

struct AuthFlowView: View {
    @StateObject var authVM = AuthViewModel()
    @Namespace var animation
    @State private var showLogin = true

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("FocusPath")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                HStack(spacing: 24) {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { showLogin = true }
                    } label: {
                        Text("Login")
                            .fontWeight(showLogin ? .bold : .regular)
                            .foregroundColor(showLogin ? .white : .white.opacity(0.7))
                            .padding(.vertical, 4)
                            .overlay(
                                Capsule()
                                    .foregroundColor(showLogin ? .white : .clear)
                                    .frame(height: 3),
                                alignment: .bottom
                            )
                    }
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { showLogin = false }
                    } label: {
                        Text("Sign Up")
                            .fontWeight(!showLogin ? .bold : .regular)
                            .foregroundColor(!showLogin ? .white : .white.opacity(0.7))
                            .padding(.vertical, 4)
                            .overlay(
                                Capsule()
                                    .foregroundColor(!showLogin ? .white : .clear)
                                    .frame(height: 3),
                                alignment: .bottom
                            )
                    }
                }
                .font(.title2)
                .padding(.bottom, 8)

                if showLogin {
                    LoginView(authVM: authVM)
                        .matchedGeometryEffect(id: "form", in: animation)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity))
                } else {
                    SignupView(authVM: authVM)
                        .matchedGeometryEffect(id: "form", in: animation)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                }

                Spacer()

                if authVM.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.3)
                        .padding(.top)
                }
            }
            .padding(.horizontal, 30)
        }
        .fullScreenCover(isPresented: $authVM.isLoggedIn) {
            MainTabView(authVM: authVM)  
        }
    }
}

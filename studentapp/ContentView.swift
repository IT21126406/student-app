import SwiftUI

struct ContentView: View {
    @StateObject var authVM = AuthViewModel()
    @State private var showLogin = false
    @State private var showSignup = false
    @State private var goHomeDirectly = false
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if authVM.isLoggedIn || goHomeDirectly {
                MainTabView(authVM: authVM)  // Pass authVM here
            } else {
                NavigationView {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 138/255, green: 102/255, blue: 232/255),
                                Color(red: 220/255, green: 190/255, blue: 230/255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        VStack(spacing: 40) {
                            Text("FocusPath")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 5)

                            Spacer()

                            VStack(spacing: 18) {
                                Button {
                                    showLogin = true
                                } label: {
                                    Text("Login")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white.opacity(0.95))
                                        .foregroundColor(.purple)
                                        .cornerRadius(14)
                                        .shadow(radius: 5)
                                }
                                .sheet(isPresented: $showLogin) {
                                    LoginView(authVM: authVM)
                                }

                                Button {
                                    showSignup = true
                                } label: {
                                    Text("Sign Up")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white.opacity(0.95))
                                        .foregroundColor(.pink.opacity(0.85))
                                        .cornerRadius(14)
                                        .shadow(radius: 5)
                                }
                                .sheet(isPresented: $showSignup) {
                                    SignupView(authVM: authVM)
                                }

                                Button {
                                    goHomeDirectly = true
                                } label: {
                                    Text("Go to Home")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.purple.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(14)
                                        .shadow(radius: 5)
                                }
                            }
                            .padding(.horizontal, 40)

                            Spacer()
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
            }

            if showSplash {
                SplashView(appName: "FocusPath") {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct SplashView: View {
    let appName: String
    var onFinish: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 138/255, green: 102/255, blue: 232/255),
                    Color(red: 220/255, green: 190/255, blue: 230/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Text(appName)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("Study smarter")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onFinish()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

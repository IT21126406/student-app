import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var agreeTerms = false
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 24) {
            
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == 0 ? Color.purple.opacity(0.12) : .clear)
                        .foregroundColor(selectedTab == 0 ? .purple : .gray)
                        .cornerRadius(8)
                }
                Button(action: { selectedTab = 1 }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == 1 ? Color.purple.opacity(0.12) : .clear)
                        .foregroundColor(selectedTab == 1 ? .purple : .gray)
                        .cornerRadius(8)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 0.5)
            .padding(.horizontal)

            
            VStack(alignment: .leading, spacing: 18) {
                Text("Please register for an account")
                    .font(.headline)

                TextField("Email Address", text: $email)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    } else {
                        SecureField("Password", text: $password)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }

                Toggle(isOn: $agreeTerms) {
                    Text("I agree to above terms & conditions")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: {
                    if agreeTerms {
                        Task { await authVM.signUp(email: email, password: password) }
                    }
                }) {
                    Text("Signup")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreeTerms ? Color.purple : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!agreeTerms)

            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .padding(.horizontal)

            HStack {
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.25))
                Text("or Sign up with")
                    .font(.caption)
                    .foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.25))
            }
            .padding(.horizontal)

            HStack(spacing: 20) {
                SocialButton(title: "Google", icon: "globe")
                SocialButton(title: "Apple", icon: "apple.logo")
                SocialButton(title: "Facebook", icon: "f.circle")
            }
            .padding(.horizontal)

            HStack {
                Text("Already have an account?")
                Button("Login") {
                   
                }
                .foregroundColor(.purple)
            }
            .padding(.top, 8)

            Text("By signing into FocusMate you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding(.vertical)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

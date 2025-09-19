import SwiftUI
import FirebaseAuth
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var selectedTab = 1

    var body: some View {
        VStack(spacing: 24) {
            
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == 0 ? Color.purple.opacity(0.12) : .clear)
                        .foregroundColor(selectedTab == 0 ? .purple : .gray)
                        .cornerRadius(10)
                }
                Button(action: { selectedTab = 1 }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == 1 ? Color.purple.opacity(0.12) : .clear)
                        .foregroundColor(selectedTab == 1 ? .purple : .gray)
                        .cornerRadius(10)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 0.5)
            .padding(.horizontal)

            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.purple)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.primary)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.purple)
                    if showPassword {
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.primary)
                    } else {
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.primary)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            await authVM.resetPassword(email: email)
                        }
                    }) {
                        Text("Forgot Password?")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .underline()
                    }
                    .padding(.leading, 4)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button {
                    Task {
                        await authVM.signIn(email: email, password: password)
                    }
                } label: {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .padding(.horizontal)

           
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.25))
                Text("or login with")
                    .font(.caption)
                    .foregroundColor(.gray)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.25))
            }
            .padding(.horizontal)

            GoogleSignInButton {
                Task {
                    await authVM.signInWithGoogle()
                }
            }
            .frame(height: 44)
            .padding(.horizontal)

           
            HStack(spacing: 20) {
                SocialButton(title: "Apple", icon: "apple.logo")
                SocialButton(title: "Facebook", icon: "f.circle")
            }
            .padding(.horizontal)

            HStack {
                Text("New to StudyMB?")
                Button("Create Account") {
                    
                }
                .foregroundColor(.purple)
            }
            .font(.footnote)
            .padding(.top)
            Spacer()
        }
        .padding(.vertical)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}


struct socialbutton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            Text(title).font(.caption)
        }
        .frame(width: 80)
    }
}

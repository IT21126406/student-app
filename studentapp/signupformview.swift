import SwiftUI

struct SignupFormView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            HStack {
                Button("Sign up") {}
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                
                Button("Login") {}
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Please register for an account")
                    .font(.headline)
                
                TextField("Email Address", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            Button(action: {}) {
                Text("Signup")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Or sign up with")
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                SocialButton(title: "Google", icon: "globe")
                SocialButton(title: "Apple", icon: "apple.logo")
                SocialButton(title: "Facebook", icon: "f.circle")
            }
            
            HStack {
                Text("Already have an account?")
                Button("Login") {}
                    .foregroundColor(.purple)
            }
            
            Text("By signing into FocusMate you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
    }
}

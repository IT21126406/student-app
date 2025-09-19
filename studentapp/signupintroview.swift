import SwiftUI

struct SignupIntroView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "person.crop.circle.badge.plus") 
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundColor(.purple)
            
            Text("Let's get you in")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Or")
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                SocialButton(title: "Google", icon: "globe")
                SocialButton(title: "Apple", icon: "apple.logo")
                SocialButton(title: "Facebook", icon: "f.circle")
            }
            
            Button(action: {}) {
                Text("Sign in with password")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            HStack {
                Text("New to StudyMB?")
                Button("Create Account") {}
                    .foregroundColor(.purple)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct SocialButton: View {
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
    }
}

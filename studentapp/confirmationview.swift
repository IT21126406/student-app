import SwiftUI

struct ConfirmationView: View {
    @State private var agreed = false
    @Binding var isConfirmed: Bool
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.85), Color.pink.opacity(0.75)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Confirmation")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 6)
                
                
                Text("Terms & Conditions")
                    .font(.headline)
                    .foregroundColor(.white)
                
                
                ScrollView {
                    Text("""
                    By using this app, you agree to comply with our Terms and Conditions and acknowledge that you have read and understood our Privacy Policy. 
                    
                    Please ensure that you read everything carefully before proceeding.
                    """)
                    .foregroundColor(.white.opacity(0.9))
                    .padding()
                }
                .frame(height: 220)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
                
                
                Toggle(isOn: $agreed) {
                    Text("I agree to the above terms & conditions")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .pink))
                
                
                Button(action: {
                    if agreed {
                        isConfirmed = true
                    }
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 6)
                }
                .opacity(agreed ? 1 : 0.5)
                .disabled(!agreed)
                
                Spacer()
            }
            .padding()
        }
    }
}


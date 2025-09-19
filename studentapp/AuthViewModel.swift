import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit
import LocalAuthentication

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func resetPassword(email: String) async {
        isLoading = true
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            errorMessage = "Password reset email sent!"
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Google client ID"
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        do {
            let presentingVC = try await getCurrentViewController()
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            guard let idToken = result.user.idToken else {
                errorMessage = "Missing Google ID token"
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: result.user.accessToken.tokenString
            )

            _ = try await Auth.auth().signIn(with: credential)
            errorMessage = nil
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func authenticateWithFaceID() async -> Bool {
        await withCheckedContinuation { continuation in
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Use Face ID to sign in"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                    DispatchQueue.main.async {
                        continuation.resume(returning: success)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private func getCurrentViewController() async throws -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let vc = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            throw NSError(domain: "NoRootVC", code: 1)
        }
        return vc
    }
}

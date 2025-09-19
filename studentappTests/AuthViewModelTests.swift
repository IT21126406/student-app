import XCTest
@testable import studentapp

final class AuthViewModelTests: XCTestCase {

    var authVM: AuthViewModel!

    @MainActor override func setUp() {
        super.setUp()
        authVM = AuthViewModel()
    }

    @MainActor override func tearDown() {
        authVM = nil
        super.tearDown()
    }

    func testSignInWithWrongCredentials() async {
       
        await authVM.signIn(email: "wrong@invalid.com", password: "incorrect")

       
        try? await Task.sleep(nanoseconds: 300_000_000)

        await MainActor.run {
            XCTAssertFalse(authVM.isLoggedIn)
            XCTAssertNotNil(authVM.errorMessage)
            print("SignIn errorMessage: \(authVM.errorMessage ?? "nil")")
        }
    }

    func testSignUpWithInvalidEmail() async {
        await authVM.signUp(email: "bademail", password: "pass123")

        try? await Task.sleep(nanoseconds: 300_000_000) 

        await MainActor.run {
            XCTAssertFalse(authVM.isLoggedIn)
            XCTAssertNotNil(authVM.errorMessage)
            print("SignUp errorMessage: \(authVM.errorMessage ?? "nil")")
        }
    }
}

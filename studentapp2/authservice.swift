import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService: ObservableObject {
    @Published var user: User?
    private var auth = Auth.auth()
    private var db = Firestore.firestore()
    
    init() {
        self.user = auth.currentUser
    }
    
    
    func signup(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self.user = user
                completion(.success(user))
                
                
                self.db.collection("users").document(user.uid).setData([
                    "email": user.email ?? "",
                    "createdAt": Timestamp(date: Date()),
                    "progress": 0,
                    "streak": 0
                ]) { err in
                    if let err = err {
                        print(" Error saving user: \(err)")
                    }
                }
            }
        }
    }
    
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self.user = user
                completion(.success(user))
            }
        }
    }
    
    
    func logout() {
        try? auth.signOut()
        self.user = nil
    }
}

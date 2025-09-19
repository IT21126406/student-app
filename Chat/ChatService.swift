import Foundation
import FirebaseAuth
import FirebaseFirestore

final class ChatService: ObservableObject {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    @Published var messages: [ChatMessage] = []

    func startListening(groupId: String) {
        stopListening()
        listener = db.collection("groups")
            .document(groupId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let docs = snapshot?.documents {
                    self.messages = docs.compactMap(ChatMessage.init(from:))
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func sendMessage(groupId: String, text: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let msg = ChatMessage(text: text, senderId: user.uid, senderName: user.displayName ?? "Anonymous")
        try await db.collection("groups")
            .document(groupId)
            .collection("messages")
            .addDocument(data: msg.dictionary)
    }
}

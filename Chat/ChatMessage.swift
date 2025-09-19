import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    var id: String = UUID().uuidString
    var text: String
    var senderId: String
    var senderName: String
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id, text, senderId, senderName, timestamp
    }

    init(id: String = UUID().uuidString, text: String, senderId: String, senderName: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = timestamp
    }

    init?(from doc: DocumentSnapshot) {
        guard
            let data = doc.data(),
            let text = data["text"] as? String,
            let senderId = data["senderId"] as? String,
            let senderName = data["senderName"] as? String,
            let ts = data["timestamp"] as? Timestamp
        else { return nil }
        self.id = doc.documentID
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = ts.dateValue()
    }

    var dictionary: [String: Any] {
        [
            "text": text,
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}

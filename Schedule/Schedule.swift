import Foundation
import FirebaseFirestore

struct Schedule: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var notes: String?
    var date: Date            
    var startTime: Date?
    var endTime: Date?
    var isFullDay: Bool
    @ServerTimestamp var createdAt: Date?

    init(id: String? = nil,
         title: String,
         notes: String? = nil,
         date: Date,
         startTime: Date? = nil,
         endTime: Date? = nil,
         isFullDay: Bool) {
        self.id = id
        self.title = title
        self.notes = notes
        self.date = Calendar.current.startOfDay(for: date)
        self.startTime = startTime
        self.endTime = endTime
        self.isFullDay = isFullDay
    }
}

import Foundation
import FirebaseCore
import FirebaseFirestore

@MainActor
final class ScheduleStore: ObservableObject {
    private let db = Firestore.firestore()
    @Published var today: [Schedule] = []
    @Published var tomorrow: [Schedule] = []

    func loadTodayAndTomorrow(reference: Date = Date()) async {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: reference)
        let tomorrowStart = cal.date(byAdding: .day, value: 1, to: todayStart)!
        let dayAfterStart = cal.date(byAdding: .day, value: 2, to: todayStart)!

        do {
            let snap = try await db.collection("schedules")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: todayStart))
                .whereField("date", isLessThan: Timestamp(date: dayAfterStart))
                .order(by: "date")
                .getDocuments()

            let all: [Schedule] = try snap.documents.map { doc in
                try doc.data(as: Schedule.self)
            }

            self.today = all.filter { $0.date >= todayStart && $0.date < tomorrowStart }
            self.tomorrow = all.filter { $0.date >= tomorrowStart }
        } catch {
            print("Load error: \(error)")
            self.today = []
            self.tomorrow = []
        }
    }

    func add(_ schedule: Schedule) async throws {
        let ref = db.collection("schedules").document()
        try ref.setData(from: schedule)
        await loadTodayAndTomorrow()
    }

    func remove(_ schedule: Schedule) async {
        guard let id = schedule.id else { return }
        do {
            try await db.collection("schedules").document(id).delete()
            await loadTodayAndTomorrow()
        } catch {
            print("Delete error: \(error)")
        }
    }
}

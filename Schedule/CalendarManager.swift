import EventKit

final class CalendarManager {
    private let store = EKEventStore()

    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do { return try await store.requestFullAccessToEvents() }
            catch { return false }
        } else {
            return await withCheckedContinuation { cont in
                store.requestAccess(to: .event) { granted, _ in
                    cont.resume(returning: granted)
                }
            }
        }
    }

    func addEvent(from schedule: Schedule) async throws {
        let granted = await requestAccess()
        guard granted else { return }

        let event = EKEvent(eventStore: store)
        event.title = schedule.title
        event.notes = schedule.notes

        let cal = Calendar.current
        let base = cal.startOfDay(for: schedule.date)

        if schedule.isFullDay {
            event.isAllDay = true
            event.startDate = base
            event.endDate = cal.date(byAdding: .day, value: 1, to: base)!
        } else {
            let start = schedule.startTime ?? base
            let end = schedule.endTime ?? cal.date(byAdding: .hour, value: 1, to: start)!
            event.startDate = start
            event.endDate = end
        }

        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }
}

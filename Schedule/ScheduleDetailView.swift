import SwiftUI

struct ScheduleDetailView: View {
    var selectedDate: Date
    var onSaved: () -> Void

    @State private var isFullDay = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var title = ""
    @State private var notes = ""
    @State private var alsoAddToCalendar = true
    @Environment(\.dismiss) private var dismiss

    private let calendarManager = CalendarManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Set Schedule")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.purple)

                HStack {
                    Image(systemName: "calendar").foregroundColor(.purple)
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Title").font(.caption).foregroundColor(.secondary)
                    TextField("Study Science", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes").font(.caption).foregroundColor(.secondary)
                    TextField("Optional", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                VStack(spacing: 16) {
                    Toggle("Full day", isOn: $isFullDay)
                    if !isFullDay {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Start Time").font(.caption).foregroundColor(.secondary)
                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("End Time").font(.caption).foregroundColor(.secondary)
                                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                        }
                    }
                    Toggle("Add to Calendar", isOn: $alsoAddToCalendar)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        Text("Confirm")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [
                                    Color(red: 138/255, green: 102/255, blue: 232/255),
                                    Color(red: 220/255, green: 190/255, blue: 230/255)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Schedule Details")
    }

    private func save() async {
        let cal = Calendar.current
        let baseDay = cal.startOfDay(for: selectedDate)

        let start: Date? = isFullDay ? nil : combine(day: baseDay, time: startTime)
        let end: Date? = isFullDay ? nil : combine(day: baseDay, time: endTime)

        let schedule = Schedule(
            title: title.isEmpty ? "Untitled" : title,
            notes: notes.isEmpty ? nil : notes,
            date: baseDay,
            startTime: start,
            endTime: end,
            isFullDay: isFullDay
        )

        do {
            try await ScheduleStore().add(schedule)
            if alsoAddToCalendar {
                try await calendarManager.addEvent(from: schedule)
            }
            onSaved()
            await MainActor.run { dismiss() }
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func combine(day: Date, time: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: time)
        return cal.date(bySettingHour: comps.hour ?? 0,
                        minute: comps.minute ?? 0,
                        second: comps.second ?? 0,
                        of: day) ?? day
    }
}

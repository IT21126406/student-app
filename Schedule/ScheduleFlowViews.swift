import SwiftUI

struct ScheduleView: View {
    @State private var selectedDate = Date()
    @State private var showDetail = false
    @StateObject private var store = ScheduleStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    ScheduleCard(title: "Today", schedules: store.today)
                    ScheduleCard(title: "Tomorrow", schedules: store.tomorrow)

                    Divider().padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select a Date")
                            .font(.subheadline)
                            .foregroundColor(Color.purple.opacity(0.8))

                        DatePicker("",
                                   selection: $selectedDate,
                                   displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.purple)
                            .padding(6)
                    }
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .padding(.horizontal)

                    Button {
                        showDetail = true
                    } label: {
                        Text("Set Schedule")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(
                                LinearGradient(colors: [
                                    Color(red: 138/255, green: 102/255, blue: 232/255),
                                    Color(red: 220/255, green: 190/255, blue: 230/255)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .navigationTitle("Your Schedule")
            .navigationDestination(isPresented: $showDetail) {
                ScheduleDetailView(selectedDate: selectedDate) {
                    Task { await store.loadTodayAndTomorrow() }
                }
            }
        }
        .task { await store.loadTodayAndTomorrow() }
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [
                            Color(red: 138/255, green: 102/255, blue: 232/255),
                            Color(red: 220/255, green: 190/255, blue: 230/255)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
            Text("Plan and track study time")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
}

struct ScheduleCard: View {
    var title: String
    var schedules: [Schedule]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white.opacity(0.95))

            if schedules.isEmpty {
                Text("No items")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            } else {
                ForEach(schedules) { s in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("• \(s.title)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.95))
                        if s.isFullDay {
                            Text("All day")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.85))
                        } else {
                            let f = Date.FormatStyle(date: .omitted, time: .shortened)
                            Text("\(s.startTime?.formatted(f) ?? "") - \(s.endTime?.formatted(f) ?? "")")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [
                Color(red: 138/255, green: 102/255, blue: 232/255),
                Color(red: 220/255, green: 190/255, blue: 230/255)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
}

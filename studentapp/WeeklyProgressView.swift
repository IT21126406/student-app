import SwiftUI
import Charts
import FirebaseAuth
import FirebaseFirestore

struct WeeklyDatum: Identifiable, Hashable {
    var id = UUID()
    var dayOrWeek: String
    var minutes: Int
}

struct WeeklyProgressView: View {
    @State private var weeklyData: [WeeklyDatum] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView("Loading weekly progress...")
                    .padding()
            } else {
                HStack {
                    Text("Weekly Progress")
                        .font(.title3.bold())
                        .foregroundColor(.purple)
                    Spacer()
                }
                .padding(.horizontal)

                Chart(weeklyData) { item in
                    BarMark(
                        x: .value("Day", item.dayOrWeek),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(Gradient(colors: [.purple, .pink]))
                    .cornerRadius(6)
                }
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 260)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.6))
                )
                .padding(.horizontal)
            }
        }
        .onAppear(perform: fetchWeeklyProgress)
        .navigationTitle("Weekly Progress")
        .navigationBarTitleDisplayMode(.inline)
        //.appBackground() // Add your custom app background modifier if any
    }

    private func fetchWeeklyProgress() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            return
        }
        let db = Firestore.firestore()

        let cal = Calendar(identifier: .iso8601)
        let w = cal.component(.weekOfYear, from: Date())
        let y = cal.component(.yearForWeekOfYear, from: Date())
        let weekKey = String(format: "%04d-W%02d", y, w)

        let daysRef = db.collection("progress")
            .document(uid)
            .collection("weekly")
            .document(weekKey)
            .collection("days")

        daysRef.getDocuments { snap, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let docs = snap?.documents, !docs.isEmpty {
                    var temp = docs.map { d in
                        WeeklyDatum(dayOrWeek: d.documentID,
                                    minutes: d.data()["minutes"] as? Int ?? (d.data()["completion"] as? Int ?? 0))
                    }
                    let order = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                    temp.sort { (order.firstIndex(of: $0.dayOrWeek) ?? 99) < (order.firstIndex(of: $1.dayOrWeek) ?? 99) }
                    self.weeklyData = temp
                } else {
                    db.collection("progress").document(uid).collection("weekly")
                        .getDocuments { snap2, error2 in
                            DispatchQueue.main.async {
                                var temp: [WeeklyDatum] = []
                                snap2?.documents.forEach { d in
                                    let val = d.data()["minutes"] as? Int ?? (d.data()["completion"] as? Int ?? 0)
                                    temp.append(WeeklyDatum(dayOrWeek: d.documentID, minutes: val))
                                }
                                let order = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                                temp.sort { (order.firstIndex(of: $0.dayOrWeek) ?? 99) < (order.firstIndex(of: $1.dayOrWeek) ?? 99) }
                                self.weeklyData = temp
                            }
                        }
                }
            }
        }
    }
}

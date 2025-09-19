import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Charts

struct MonthlyDatum: Identifiable {
    var id = UUID()
    var day: String
    var completion: Int
}

struct MonthlyProgressView: View {
    @State private var monthlyData: [MonthlyDatum] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 28) {
            if isLoading {
                ProgressView("Loading monthly progress...")
                    .progressViewStyle(.circular)
                    .tint(.pink)
                    .scaleEffect(1.4)
            } else {
                Text("Your Monthly Progress")
                    .font(.title3.bold())
                    .foregroundColor(.pink)

                Chart(monthlyData) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Completion %", item.completion)
                    )
                    .foregroundStyle(Gradient(colors: [.pink, .purple]))
                    .cornerRadius(6)
                }
                .frame(height: 260)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.6))
                )
                .padding(.horizontal)
            }
        }
        .padding(.top, 12)
        .onAppear(perform: fetchMonthlyProgress)
        .navigationTitle("Monthly Progress")
        .navigationBarTitleDisplayMode(.inline)
       
    }
    
    private func fetchMonthlyProgress() {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.monthlyData = []
                self.isLoading = false
            }
            return
        }
        
        let db = Firestore.firestore()
        
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM"
        let key = fmt.string(from: Date())
        
        db.collection("progress")
            .document(uid)
            .collection("monthly")
            .document(key)
            .collection("days")
            .getDocuments { snap, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let docs = snap?.documents, !docs.isEmpty {
                        var data: [MonthlyDatum] = []
                        for doc in docs {
                            let day = doc.documentID
                            let completion = doc.data()["completion"] as? Int ?? 0
                            data.append(MonthlyDatum(day: day, completion: completion))
                        }
                        
                        data.sort { $0.day < $1.day }
                        self.monthlyData = data
                    } else {
                        self.monthlyData = []
                    }
                }
            }
    }
}

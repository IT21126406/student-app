import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct StreakChallenge: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let requiredDays: Int
    var isCompleted: Bool
    let badge: String
}

struct StreakChallengeView: View {
    @State private var streakCount = 0
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var confirmAction: (() -> Void)? = nil

    @State private var challenges: [StreakChallenge] = [
        StreakChallenge(name: "7-Day Streak", requiredDays: 7, isCompleted: false, badge: "🔥"),
        StreakChallenge(name: "14-Day Streak", requiredDays: 14, isCompleted: false, badge: "🏆"),
        StreakChallenge(name: "30-Day Streak", requiredDays: 30, isCompleted: false, badge: "🎓")
    ]

    var body: some View {
        VStack(spacing: 18) {
            if isLoading {
                ProgressView("Loading streak challenges...")
            } else {
                Text("Current Streak: \(streakCount) days")
                    .font(.title3.bold())
                    .foregroundColor(.purple)
                    .padding(.bottom, 4)

                Button(action: handleStreakButton) {
                    Text(streakCount == 0 ? "Start Streak Challenge" : "Mark Today Complete")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(LinearGradient.appPurplePink)

                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Confirm"),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Confirm"), action: { confirmAction?() }),
                        secondaryButton: .cancel()
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Streak Challenges")
                        .font(.headline)
                        .foregroundColor(.purple)
                        .padding(.top, 6)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(challenges.indices, id: \.self) { i in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(challenges[i].name)
                                            .fontWeight(.bold)
                                        Text("Requires \(challenges[i].requiredDays) days")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if challenges[i].isCompleted {
                                        Text(challenges[i].badge).font(.title2)
                                    } else if streakCount >= challenges[i].requiredDays {
                                        Text("Unlockable!")
                                            .font(.subheadline)
                                            .foregroundColor(.pink)
                                    }
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.6))
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 12)
        .onAppear(perform: fetchStreak)
        .navigationTitle("Streak Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
    }

    

    private func handleStreakButton() {
        if streakCount == 0 {
            alertMessage = "Start your streak challenge?"
            confirmAction = startStreak
        } else {
            alertMessage = "Mark today as complete?"
            confirmAction = updateStreak
        }
        showAlert = true
    }

    private func startStreak() {
        streakCount = 1
        saveStreak()
    }

    private func updateStreak() {
        streakCount += 1
        saveStreak()
    }

    
    private func fetchStreak() {
        guard let uid = Auth.auth().currentUser?.uid else {
            streakCount = 0
            isLoading = false
            return
        }
        let db = Firestore.firestore()
        db.collection("progress").document(uid).collection("meta").document("streak")
            .getDocument { snap, _ in
                if let data = snap?.data() {
                    streakCount = data["days"] as? Int ?? 0
                    if let completed = data["completedChallenges"] as? [String] {
                        for i in challenges.indices {
                            if completed.contains(challenges[i].name) {
                                challenges[i].isCompleted = true
                            }
                        }
                    }
                } else {
                    streakCount = 0
                }
                isLoading = false
            }
    }

    private func saveStreak() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var unlockedBadges: [String] = []
        for i in challenges.indices {
            if !challenges[i].isCompleted && streakCount >= challenges[i].requiredDays {
                challenges[i].isCompleted = true
                unlockedBadges.append(challenges[i].badge)
            }
        }

        let db = Firestore.firestore()
        let streakRef = db.collection("progress").document(uid).collection("meta").document("streak")

        streakRef.setData([
            "days": streakCount,
            "completedChallenges": challenges.filter { $0.isCompleted }.map { $0.name }
        ], merge: true)

        if !unlockedBadges.isEmpty {
            let journeyRef = db.collection("progress").document(uid).collection("meta").document("journey")
            journeyRef.setData(["unlockedBadges": FieldValue.arrayUnion(unlockedBadges)], merge: true)
        }
    }
}

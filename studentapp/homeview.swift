import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var progressWeek: Double = 0.80
    @State private var reminders: [String] = [
        "Reminder: Japanese group at 6:00 PM. Prep notes and be on time!",
        "Scan 3 more notes to earn the next badge!",
        "UI/UX group meets Saturday–Sunday."
    ]

    @State private var groups: [StudyGroup] = [
        .init(name: "UI/UX Group", weekday: "Sat–Sun", description: "Design critique sessions and portfolio reviews."),
        .init(name: "Japanese Group", weekday: "Sunday", description: "JLPT practice and speaking drills."),
        .init(name: "Korean Group", weekday: "Monday", description: "Hangul reading and K-drama listening practice."),
        .init(name: "Maths Group", weekday: "Saturday", description: "Calculus problem sets and exam prep.")
    ]

    var filteredGroups: [StudyGroup] {
        guard !searchText.isEmpty else { return groups }
        return groups.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.weekday.localizedCaseInsensitiveContains(searchText)
            || $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    searchShortcuts

                    heroCarousel

                    
                    VStack(spacing: 16) {
                        Text("Quick Tools")
                            .font(.headline)
                            .foregroundColor(Color.purple.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        NavigationLink(destination: ScanNotesView()) {
                            QuickToolButton(icon: "doc.text.viewfinder", label: "Scan Notes")
                        }
                        .padding(.horizontal)
                    }

                   
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your Groups")
                                .font(.headline)
                                .foregroundColor(Color.purple.opacity(0.85))
                            Spacer()
                            NavigationLink("See all") {
                                GroupsListView(groups: filteredGroups)
                            }
                            .font(.subheadline)
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(filteredGroups) { g in
                                    NavigationLink {
                                        GroupDetailView(group: g)
                                    } label: {
                                        GroupButton(title: g.name)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search notes, groups")
            .searchSuggestions {
                if searchText.isEmpty {
                    Text("UI/UX").searchCompletion("UI/UX")
                    Text("Japanese").searchCompletion("Japanese")
                    Text("Maths").searchCompletion("Maths")
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good Morning,")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Alessa")
                    .font(.title2.weight(.bold))
                    .foregroundColor(Color.purple.opacity(0.85))
            }
            Spacer()
            NavigationLink {
                RemindersView(reminders: reminders)
            } label: {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(Color.purple.opacity(0.7))
            }
        }
        .padding(.horizontal)
    }

    private var searchShortcuts: some View {
        HStack(spacing: 8) {
            Label("Search", systemImage: "magnifyingglass")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [
                        Color(red: 138/255, green: 102/255, blue: 232/255),
                        Color(red: 255/255, green: 182/255, blue: 193/255)
                    ], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
            Button {
               
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.purple)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }

    private var heroCarousel: some View {
        TabView {
            NavigationLink {
                WeeklyProgressDetailView(progress: progressWeek)
            } label: {
                WeeklyProgressCard(progress: progressWeek)
                    .padding(.vertical, 2)
            }

            NavigationLink {
                TodaysScheduleDetailView(reminder: reminders.first ?? "Stay productive!")
            } label: {
                TodaysScheduleCard(text: reminders.first ?? "Stay productive!")
                    .padding(.vertical, 2)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 190)
        .padding(.horizontal)
    }
}



struct StudyGroup: Identifiable {
    let id = UUID()
    let name: String
    let weekday: String
    let description: String
}



struct GroupsListView: View {
    var groups: [StudyGroup]

    var body: some View {
        List(groups) { g in
            NavigationLink(destination: GroupDetailView(group: g)) {
                HStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 64, height: 48)
                        .overlay(Image(systemName: "person.3.fill").foregroundColor(.purple))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(g.name).font(.headline)
                        Text("\(g.weekday) • \(g.description)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("All Groups")
    }
}

struct GroupDetailView: View {
    var group: StudyGroup
    @State private var members: [String] = ["Alice", "Edward", "Esther"]
    @State private var isJoining = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
               
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(colors: [
                                Color.purple.opacity(0.4),
                                Color.pink.opacity(0.3)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(height: 140)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(group.name)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.primary)
                        Text("Meets: \(group.weekday)")
                            .foregroundColor(.secondary)
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding()
                }
                .padding(.horizontal)

                
                HStack(spacing: 12) {
                    Button(isJoining ? "Leave Group" : "Join Group") {
                        withAnimation { isJoining.toggle() }
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("Message Group") {
                        Text("Group chat for \(group.name)")
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Members")
                        .font(.headline)
                    ForEach(members, id: \.self) { m in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.purple)
                            Text(m)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}



struct WeeklyProgressCard: View {
    var progress: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 138/255, green: 102/255, blue: 232/255),
                        Color(red: 255/255, green: 182/255, blue: 193/255)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    Text("%")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 10)
                        Capsule()
                            .fill(LinearGradient(colors: [.white, .white.opacity(0.7)],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(10, geo.size.width * progress), height: 10)
                    }
                }
                .frame(height: 10)

                Text("Update your scans to keep the streak going this week.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }
}

struct TodaysScheduleCard: View {
    var text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 138/255, green: 102/255, blue: 232/255),
                        Color(red: 220/255, green: 190/255, blue: 230/255)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Schedule")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.95))
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }
            .padding()
        }
    }
}

struct QuickToolButton: View {
    var icon: String
    var label: String

    var body: some View {
        HStack {
            Image(systemName: icon).font(.title2)
            Text(label).font(.headline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(
            LinearGradient(colors: [
                Color(red: 138/255, green: 102/255, blue: 232/255),
                Color(red: 255/255, green: 182/255, blue: 193/255)
            ], startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(16)
        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct GroupButton: View {
    var title: String
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 138/255, green: 102/255, blue: 232/255).opacity(0.2),
                            Color(red: 255/255, green: 182/255, blue: 193/255).opacity(0.2)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 130, height: 90)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .font(.title)
                        .foregroundColor(Color.purple.opacity(0.7))
                )
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundColor(Color.purple.opacity(0.85))
        }
        .contentShape(Rectangle())
    }
}



struct WeeklyProgressDetailView: View {
    var progress: Double
    var body: some View {
        VStack(spacing: 20) {
            Text("Weekly Progress")
                .font(.title.bold())
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
            Spacer()
        }
        .padding()
    }
}

struct TodaysScheduleDetailView: View {
    var reminder: String
    var body: some View {
        VStack(spacing: 20) {
            Text("Today's Schedule")
                .font(.title.bold())
            Text(reminder)
                .font(.headline)
                .foregroundColor(.purple)
            Spacer()
        }
        .padding()
    }
}

struct RemindersView: View {
    var reminders: [String]
    var body: some View {
        List(reminders, id: \.self) { reminder in
            Text(reminder)
        }
        .navigationTitle("Reminders")
    }
}

struct ScanNotesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.purple)
            Text("Scan Notes")
                .font(.largeTitle.bold())
            Text("Use your camera to scan and save study notes.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Scan Notes")
    }
}

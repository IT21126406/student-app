import SwiftUI

struct GroupsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Study Groups")
                    .font(.largeTitle)
                    .foregroundColor(.purple)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(1..<6) { i in
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.white)
                                Text("Group \(i)")
                                    .foregroundColor(.white)
                                Spacer()
                                
                                NavigationLink(destination: GroupDetailsScreen(groupName: "Group \(i)")) {
                                    Text("Join")
                                        .padding(8)
                                        .background(Color.pink)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.purple.opacity(0.6))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Groups")
        }
    }
}

// Renamed to avoid redeclaration
struct GroupDetailsScreen: View {
    var groupName: String
    
    @State private var searchText: String = ""
    @State private var members: [String] = ["Alice", "Edward", "Esther Howard"]
    
    private let directory: [String] = [
        "Daniel", "Cecilia", "Isha", "Mohit", "Yuki", "Aarav", "Noah", "Aria", "Ben", "Chloe"
    ]
    
    private var filteredCandidates: [String] {
        let existing = Set(members)
        let base = directory.filter { !existing.contains($0) }
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(groupName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            Text("Welcome to \(groupName)!")
                .font(.title2)
                .foregroundColor(.gray)
            
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
            .background(Color.white.opacity(0.6))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Add Members")
                    .font(.headline)
                
                TextField("Search people to invite", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if filteredCandidates.isEmpty && !searchText.isEmpty {
                    Text("No matches found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredCandidates, id: \.self) { user in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user)
                                        Text("Tap Add to invite")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button("Add") {
                                        withAnimation {
                                            members.append(user)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxHeight: 180)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

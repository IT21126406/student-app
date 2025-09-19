import SwiftUI

struct MainTabView: View {
    @ObservedObject var authVM: AuthViewModel  // Injected auth view model

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            GroupsView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("My Groups")
                }

            ScanNotesView()
                .tabItem {
                    Image(systemName: "doc.text.viewfinder")
                    Text("Scan Notes")
                }

            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }

            ProfileView(authVM: authVM)  // Pass authVM here
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .accentColor(.purple)
    }
}

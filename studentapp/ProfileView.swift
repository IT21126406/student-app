import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var authVM: AuthViewModel

    @State private var username: String = "Alessa"
    @State private var email: String = "alessa@example.com"
    @State private var bio: String = "Learning Japanese and UI/UX."
    @State private var profileImage: Image? = nil

    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ZstackAvatar(profileImage: $profileImage, showPicker: $showEdit)

                    detailsCard

                    actionButtons

                    signOutButton
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") { showEdit = true }
                }
            }
            .sheet(isPresented: $showEdit) {
                EditProfileView(username: $username,
                                email: $email,
                                bio: $bio,
                                profileImage: $profileImage)
            }
            
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 138/255, green: 102/255, blue: 232/255),
                        Color(red: 255/255, green: 182/255, blue: 193/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(username)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)

            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.purple)
                Text(email)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Text(bio)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            NavigationLink {
                WeeklyProgressView()
            } label: {
                Text("View Weekly Progress")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(prominentButtonStyle)

            NavigationLink {
                MonthlyProgressView()
            } label: {
                Text("View Monthly Progress")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(prominentButtonStyle)

            NavigationLink {
                StreakChallengeView()
            } label: {
                Text("Streak Challenge")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(prominentButtonStyle)

            NavigationLink {
                JourneyMapView()
            } label: {
                Text("Journey Map")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(prominentButtonStyle)
        }
        .padding(.horizontal)
    }

    private var signOutButton: some View {
        Button("Sign Out") {
            do {
                try Auth.auth().signOut()
                authVM.isLoggedIn = false
            } catch {
                authVM.errorMessage = error.localizedDescription
            }
        }
        .foregroundColor(.red)
        .bold()
        .padding(.top, 24)
    }

    private var prominentButtonStyle: some ButtonStyle {
        ProminentButtonStyle()
    }
}


private struct ProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 138/255, green: 102/255, blue: 232/255),
                        Color(red: 255/255, green: 182/255, blue: 193/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: Color(red: 138/255, green: 102/255, blue: 232/255).opacity(0.4),
                    radius: 6, x: 0, y: 3)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private struct ZstackAvatar: View {
    @Binding var profileImage: Image?
    @Binding var showPicker: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = profileImage {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(.purple.opacity(0.3))
            }
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: 36, height: 36)
                .overlay(
                    Button {
                        showPicker = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.purple)
                    }
                )
                .offset(x: 4, y: 4)
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.purple, lineWidth: 3))
        .shadow(radius: 7)
        .padding()
    }
}

struct EditProfileView: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var bio: String
    @Binding var profileImage: Image?

    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Photo") {
                    HStack(spacing: 16) {
                        if let img = profileImage {
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(.purple.opacity(0.3))
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                        }
                        Button("Change Photo") {
                            showPhotoPicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                Section("Basic Info") {
                    TextField("Name", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                Section("About") {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .photosPicker(isPresented: $showPhotoPicker,
                          selection: $pickerItem,
                          matching: .images)
            .onChange(of: pickerItem) { newValue in
                guard let item = newValue else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiimage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiimage)
                    }
                }
            }
        }
    }
}

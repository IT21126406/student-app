import SwiftUI
import FirebaseAuth

struct ChatView: View {
    let groupId: String
    let groupName: String

    @StateObject private var chat = ChatService()
    @State private var inputText = ""
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chat.messages) { m in
                            MessageRow(message: m)
                                .id(m.id)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                }
                .onChange(of: chat.messages.count) { _ in
                    if let last = chat.messages.last?.id {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
                .onAppear { scrollProxy = proxy }
            }

            HStack(spacing: 8) {
                TextField("Message \(groupName)...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task {
                        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        do {
                            try await chat.sendMessage(groupId: groupId, text: text)
                            inputText = ""
                        } catch {
                            print("Send failed: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chat.startListening(groupId: groupId)
        }
        .onDisappear {
            chat.stopListening()
        }
    }
}

private struct MessageRow: View {
    let message: ChatMessage
    var isMe: Bool {
        Auth.auth().currentUser?.uid == message.senderId
    }

    var body: some View {
        HStack {
            if isMe { Spacer() }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(10)
                    .background(isMe ? Color.purple.opacity(0.15) : Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            if !isMe { Spacer() }
        }
    }
}

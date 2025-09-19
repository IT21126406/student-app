import SwiftUI

struct socialButton: View {
    let title: String
    let icon: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.caption)
        }
        .frame(width: 80)
    }
}

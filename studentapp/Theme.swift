import SwiftUI

extension LinearGradient {
    static var appPurplePink: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 138/255, green: 102/255, blue: 232/255),
                Color(red: 220/255, green: 190/255, blue: 230/255)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 255/255, green: 210/255, blue: 210/255),
                        Color(red: 210/255, green: 190/255, blue: 255/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func appBackground() -> some View { modifier(GradientBackground()) }
}

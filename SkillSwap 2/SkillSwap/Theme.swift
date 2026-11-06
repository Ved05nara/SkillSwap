import SwiftUI

enum AppTheme {
    static let accent = Color.indigo
    static let background = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
}

struct SkillTag: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.accent.opacity(0.10))
            .foregroundStyle(AppTheme.accent)
            .clipShape(Capsule())
    }
}

struct StudentAvatar: View {
    let initials: String
    var body: some View {
        Text(initials)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 54, height: 54)
            .background(
                LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(Circle())
    }
}

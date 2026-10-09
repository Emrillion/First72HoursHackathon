import SwiftUI

enum CareTheme {
    static let teal = Color(red: 23/255, green: 107/255, blue: 98/255)
    static let ink = Color(red: 23/255, green: 60/255, blue: 56/255)
    static let muted = Color(red: 82/255, green: 107/255, blue: 101/255)
    static let cloud = Color(red: 247/255, green: 249/255, blue: 245/255)
    static let mint = Color(red: 223/255, green: 240/255, blue: 232/255)
    static let amber = Color(red: 128/255, green: 80/255, blue: 14/255)
    static let lilac = Color(red: 235/255, green: 232/255, blue: 244/255)
}

struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 48).padding(.horizontal, 12).padding(.vertical, 4)
            .foregroundStyle(.white).background(enabled ? CareTheme.teal : CareTheme.muted)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct CareCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content }
            .frame(maxWidth: .infinity, alignment: .leading).padding(20)
            .background(.white).clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct DemoNotice: View {
    var body: some View {
        Label("Demo only · fictional people & services", systemImage: "sparkles")
            .font(.footnote).foregroundStyle(CareTheme.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("demoNotice")
    }
}

struct StatusBadge: View {
    let status: TaskStatus
    var symbol: String {
        switch status {
        case .needsHelp: return "hand.raised"
        case .claimed: return "person.crop.circle.badge.checkmark"
        case .arranged: return "calendar.badge.checkmark"
        case .completed: return "checkmark.circle.fill"
        }
    }
    var body: some View {
        Label(status.rawValue, systemImage: symbol).font(.subheadline.weight(.semibold))
            .foregroundStyle(status == .needsHelp ? CareTheme.amber : CareTheme.ink)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(status == .needsHelp ? Color(red: 1, green: 240/255, blue: 217/255) : (status == .completed ? CareTheme.lilac : CareTheme.mint))
            .clipShape(Capsule())
    }
}

struct EmptyMessage: View {
    let symbol: String
    let title: String
    let message: String
    var body: some View {
        CareCard {
            Image(systemName: symbol).font(.largeTitle).foregroundStyle(CareTheme.teal)
            Text(title).font(.title2.bold())
            Text(message).foregroundStyle(CareTheme.muted)
        }
    }
}

extension Date {
    var careDate: String { formatted(.dateTime.month(.abbreviated).day().hour().minute()) }
}

import Foundation
import SwiftUI

enum FocusMode: String, Codable, CaseIterable, Identifiable {
    case morning
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning:
            return "Morning"
        case .evening:
            return "Evening"
        }
    }

    var systemImage: String {
        switch self {
        case .morning:
            return "sun.max.fill"
        case .evening:
            return "moon.fill"
        }
    }
}

struct FamilyMember: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var role: String
    var initials: String
    var colorHex: String

    var color: Color {
        Color(hex: colorHex)
    }
}

struct ScheduleItem: Identifiable, Codable, Hashable {
    let id: UUID
    var time: String
    var title: String
    var owner: String
    var place: String
}

struct Chore: Identifiable, Codable, Hashable {
    let id: UUID
    var task: String
    var owner: String
    var due: String
    var isDone: Bool
}

struct HouseholdNote: Identifiable, Codable, Hashable {
    enum Tone: String, Codable {
        case info
        case alert
        case success
    }

    let id: UUID
    var text: String
    var tone: Tone
}

struct Meal: Identifiable, Codable, Hashable {
    let id: UUID
    var day: String
    var title: String
    var tag: String
}

struct HouseholdState: Codable {
    var focusMode: FocusMode
    var chores: [Chore]
    var notes: [HouseholdNote]

    static let defaults = HouseholdState(
        focusMode: .morning,
        chores: [
            Chore(id: UUID(), task: "Pack lunches", owner: "Dana", due: "Before 7:10", isDone: true),
            Chore(id: UUID(), task: "Feed plants", owner: "Nora", due: "After school", isDone: false),
            Chore(id: UUID(), task: "Load dishwasher", owner: "Theo", due: "After dinner", isDone: false)
        ],
        notes: [
            HouseholdNote(id: UUID(), text: "Bring library books back by Friday.", tone: .info),
            HouseholdNote(id: UUID(), text: "Permission slip needs a signature tonight.", tone: .alert),
            HouseholdNote(id: UUID(), text: "Soccer snacks are already in the garage fridge.", tone: .success)
        ]
    )
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}

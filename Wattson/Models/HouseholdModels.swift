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

struct WeatherDay: Identifiable, Codable, Hashable {
    let id: UUID
    var day: String
    var condition: String
    var high: Int
    var low: Int
    var precipitationChance: Int
    var systemImage: String
}

struct CalendarEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var day: String
    var date: String
    var time: String
    var title: String
    var owner: String
    var location: String
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

struct GroceryItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var isChecked: Bool
}

struct BudgetCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var monthlyLimit: Double
    var spent: Double

    var remaining: Double {
        monthlyLimit - spent
    }

    var progress: Double {
        guard monthlyLimit > 0 else {
            return 0
        }

        return min(spent / monthlyLimit, 1)
    }
}

struct HouseholdState: Codable {
    var focusMode: FocusMode
    var chores: [Chore]
    var notes: [HouseholdNote]
    var groceries: [GroceryItem]
    var budgetCategories: [BudgetCategory]

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
        ],
        groceries: [
            GroceryItem(id: UUID(), name: "Milk", category: "Dairy", isChecked: false),
            GroceryItem(id: UUID(), name: "Apples", category: "Produce", isChecked: false),
            GroceryItem(id: UUID(), name: "Pasta", category: "Pantry", isChecked: true),
            GroceryItem(id: UUID(), name: "Dish soap", category: "Household", isChecked: false)
        ],
        budgetCategories: [
            BudgetCategory(id: UUID(), name: "Groceries", monthlyLimit: 900, spent: 612),
            BudgetCategory(id: UUID(), name: "Household", monthlyLimit: 350, spent: 126),
            BudgetCategory(id: UUID(), name: "Activities", monthlyLimit: 500, spent: 280),
            BudgetCategory(id: UUID(), name: "Dining", monthlyLimit: 300, spent: 94)
        ]
    )

    enum CodingKeys: String, CodingKey {
        case focusMode
        case chores
        case notes
        case groceries
        case budgetCategories
    }

    init(
        focusMode: FocusMode,
        chores: [Chore],
        notes: [HouseholdNote],
        groceries: [GroceryItem],
        budgetCategories: [BudgetCategory]
    ) {
        self.focusMode = focusMode
        self.chores = chores
        self.notes = notes
        self.groceries = groceries
        self.budgetCategories = budgetCategories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = HouseholdState.defaults

        focusMode = try container.decodeIfPresent(FocusMode.self, forKey: .focusMode) ?? defaults.focusMode
        chores = try container.decodeIfPresent([Chore].self, forKey: .chores) ?? defaults.chores
        notes = try container.decodeIfPresent([HouseholdNote].self, forKey: .notes) ?? defaults.notes
        groceries = try container.decodeIfPresent([GroceryItem].self, forKey: .groceries) ?? defaults.groceries
        budgetCategories = try container.decodeIfPresent([BudgetCategory].self, forKey: .budgetCategories) ?? defaults.budgetCategories
    }
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

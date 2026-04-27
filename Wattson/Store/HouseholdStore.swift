import Foundation

@MainActor
final class HouseholdStore: ObservableObject {
    @Published private(set) var family: [FamilyMember]
    @Published private(set) var schedule: [ScheduleItem]
    @Published private(set) var meals: [Meal]
    @Published private(set) var weatherForecast: [WeatherDay]
    @Published private(set) var calendarEvents: [CalendarEvent]
    @Published var state: HouseholdState {
        didSet {
            save()
        }
    }

    private let stateURL: URL

    init() {
        family = [
            FamilyMember(id: UUID(), name: "Dana", role: "Parent", initials: "DG", colorHex: "#0F766E"),
            FamilyMember(id: UUID(), name: "Maya", role: "School", initials: "MG", colorHex: "#7C3AED"),
            FamilyMember(id: UUID(), name: "Theo", role: "Practice", initials: "TG", colorHex: "#EA580C"),
            FamilyMember(id: UUID(), name: "Nora", role: "Home", initials: "NG", colorHex: "#BE123C")
        ]

        schedule = [
            ScheduleItem(id: UUID(), time: "7:20", title: "School drop-off", owner: "Maya", place: "North entrance"),
            ScheduleItem(id: UUID(), time: "8:00", title: "Team standup", owner: "Dana", place: "Office"),
            ScheduleItem(id: UUID(), time: "3:45", title: "Piano lesson", owner: "Theo", place: "Maple Studio"),
            ScheduleItem(id: UUID(), time: "6:15", title: "Family dinner", owner: "Everyone", place: "Kitchen")
        ]

        meals = [
            Meal(id: UUID(), day: "Mon", title: "Sheet pan tacos", tag: "20 min"),
            Meal(id: UUID(), day: "Tue", title: "Pesto pasta", tag: "Vegetarian"),
            Meal(id: UUID(), day: "Wed", title: "Leftover night", tag: "Easy"),
            Meal(id: UUID(), day: "Thu", title: "Rice bowls", tag: "Prep ahead")
        ]

        weatherForecast = [
            WeatherDay(id: UUID(), day: "Mon", condition: "Partly cloudy", high: 72, low: 54, precipitationChance: 20, systemImage: "cloud.sun.fill"),
            WeatherDay(id: UUID(), day: "Tue", condition: "Sunny", high: 76, low: 55, precipitationChance: 5, systemImage: "sun.max.fill"),
            WeatherDay(id: UUID(), day: "Wed", condition: "Light rain", high: 67, low: 52, precipitationChance: 65, systemImage: "cloud.rain.fill"),
            WeatherDay(id: UUID(), day: "Thu", condition: "Cloudy", high: 69, low: 53, precipitationChance: 30, systemImage: "cloud.fill"),
            WeatherDay(id: UUID(), day: "Fri", condition: "Sunny", high: 74, low: 56, precipitationChance: 10, systemImage: "sun.max.fill")
        ]

        calendarEvents = [
            CalendarEvent(id: UUID(), day: "Mon", date: "Apr 27", time: "7:20 AM", title: "School drop-off", owner: "Maya", location: "North entrance"),
            CalendarEvent(id: UUID(), day: "Tue", date: "Apr 28", time: "5:30 PM", title: "Soccer practice", owner: "Theo", location: "Field 3"),
            CalendarEvent(id: UUID(), day: "Wed", date: "Apr 29", time: "6:00 PM", title: "Budget check-in", owner: "Dana", location: "Kitchen"),
            CalendarEvent(id: UUID(), day: "Thu", date: "Apr 30", time: "3:45 PM", title: "Piano lesson", owner: "Maya", location: "Maple Studio"),
            CalendarEvent(id: UUID(), day: "Fri", date: "May 1", time: "6:15 PM", title: "Family dinner", owner: "Everyone", location: "Home")
        ]

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        stateURL = documentsDirectory.appendingPathComponent("wattson-state.json")
        state = Self.loadState(from: stateURL)
    }

    var completedChoreCount: Int {
        state.chores.filter(\.isDone).count
    }

    var choreProgress: Int {
        guard !state.chores.isEmpty else {
            return 0
        }

        return Int((Double(completedChoreCount) / Double(state.chores.count) * 100).rounded())
    }

    var nextEvent: ScheduleItem {
        schedule.first { $0.time > "12:00" } ?? schedule[0]
    }

    var groceryRemainingCount: Int {
        state.groceries.filter { !$0.isChecked }.count
    }

    var monthlyBudgetLimit: Double {
        state.budgetCategories.reduce(0) { $0 + $1.monthlyLimit }
    }

    var monthlyBudgetSpent: Double {
        state.budgetCategories.reduce(0) { $0 + $1.spent }
    }

    var monthlyBudgetRemaining: Double {
        monthlyBudgetLimit - monthlyBudgetSpent
    }

    var monthlyBudgetProgress: Double {
        guard monthlyBudgetLimit > 0 else {
            return 0
        }

        return min(monthlyBudgetSpent / monthlyBudgetLimit, 1)
    }

    func setFocusMode(_ focusMode: FocusMode) {
        state.focusMode = focusMode
    }

    func addChore(task: String, owner: String) {
        let trimmedTask = task.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTask.isEmpty else {
            return
        }

        let due = state.focusMode == .morning ? "Today" : "Tonight"
        state.chores.append(Chore(id: UUID(), task: trimmedTask, owner: owner, due: due, isDone: false))
    }

    func toggleChore(_ chore: Chore) {
        guard let index = state.chores.firstIndex(where: { $0.id == chore.id }) else {
            return
        }

        state.chores[index].isDone.toggle()
    }

    func deleteChore(_ chore: Chore) {
        state.chores.removeAll { $0.id == chore.id }
    }

    func addNote(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return
        }

        state.notes.insert(HouseholdNote(id: UUID(), text: trimmedText, tone: .info), at: 0)
    }

    func addGroceryItem(name: String, category: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        state.groceries.append(
            GroceryItem(
                id: UUID(),
                name: trimmedName,
                category: trimmedCategory.isEmpty ? "General" : trimmedCategory,
                isChecked: false
            )
        )
    }

    func toggleGroceryItem(_ item: GroceryItem) {
        guard let index = state.groceries.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        state.groceries[index].isChecked.toggle()
    }

    func deleteGroceryItem(_ item: GroceryItem) {
        state.groceries.removeAll { $0.id == item.id }
    }

    func addBudgetSpend(category: BudgetCategory, amount: Double) {
        guard amount > 0, let index = state.budgetCategories.firstIndex(where: { $0.id == category.id }) else {
            return
        }

        state.budgetCategories[index].spent += amount
    }

    func reset() {
        state = .defaults
    }

    private static func loadState(from url: URL) -> HouseholdState {
        guard
            let data = try? Data(contentsOf: url),
            let state = try? JSONDecoder().decode(HouseholdState.self, from: data)
        else {
            return .defaults
        }

        return state
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }

        try? data.write(to: stateURL, options: [.atomic])
    }
}

import Foundation

@MainActor
final class HouseholdStore: ObservableObject {
    @Published private(set) var family: [FamilyMember]
    @Published private(set) var schedule: [ScheduleItem]
    @Published private(set) var meals: [Meal]
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

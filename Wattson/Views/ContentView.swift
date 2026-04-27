import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: HouseholdStore
    @State private var selectedOwner = "Dana"
    @State private var newChore = ""
    @State private var newNote = ""
    @State private var newGroceryItem = ""
    @State private var newGroceryCategory = "General"
    @State private var selectedBudgetCategory = "Groceries"
    @State private var budgetSpendAmount = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statusGrid
                    dashboard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(Color.wattsonBackground.ignoresSafeArea())
            .navigationTitle("Wattson")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Reset", systemImage: "arrow.counterclockwise") {
                        store.reset()
                    }
                }
            }
        }
        .onAppear {
            selectedOwner = store.family.first?.name ?? "Dana"
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Glassow household")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("Family tracker")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)

            Picker("Focus mode", selection: Binding(
                get: { store.state.focusMode },
                set: { store.setFocusMode($0) }
            )) {
                ForEach(FocusMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var statusGrid: some View {
        LazyVGrid(columns: adaptiveColumns(minimum: 210), spacing: 12) {
            StatusTile(
                title: "Weather",
                value: "\(store.weatherForecast.first?.high ?? 0) deg",
                detail: store.weatherForecast.first?.condition ?? "Forecast",
                systemImage: store.weatherForecast.first?.systemImage ?? "cloud.sun.fill"
            )

            StatusTile(
                title: "Next up",
                value: store.nextEvent.title,
                detail: "\(store.nextEvent.time) - \(store.nextEvent.place)",
                systemImage: "bell.badge.fill"
            )

            StatusTile(
                title: "Chores",
                value: "\(store.completedChoreCount)/\(store.state.chores.count) done",
                detail: "\(store.choreProgress)% of today cleared",
                systemImage: "checkmark.circle.fill"
            )

            StatusTile(
                title: "Dinner",
                value: store.meals.first?.title ?? "Plan dinner",
                detail: store.meals.first?.tag ?? "Household",
                systemImage: "fork.knife.circle.fill"
            )

            StatusTile(
                title: "Groceries",
                value: "\(store.groceryRemainingCount) to buy",
                detail: "\(store.state.groceries.count) items on the list",
                systemImage: "cart.fill"
            )

            StatusTile(
                title: "Budget",
                value: currency(store.monthlyBudgetRemaining),
                detail: "left this month",
                systemImage: "creditcard.fill"
            )
        }
    }

    private var dashboard: some View {
        LazyVGrid(columns: adaptiveColumns(minimum: 320), spacing: 16) {
            Panel(title: "5-day forecast", subtitle: "Weather", systemImage: "cloud.sun.fill") {
                WeatherForecastView(days: store.weatherForecast)
            }

            Panel(title: "Calendar", subtitle: "This week", systemImage: "calendar") {
                VStack(spacing: 12) {
                    ForEach(store.calendarEvents) { event in
                        CalendarEventRow(event: event)
                    }
                }
            }

            Panel(title: "Shared schedule", subtitle: "Today", systemImage: "calendar") {
                VStack(spacing: 12) {
                    ForEach(store.schedule) { item in
                        ScheduleRow(item: item)
                    }
                }
            }

            Panel(title: "Chores", subtitle: "Keep moving", systemImage: "list.bullet.clipboard") {
                VStack(spacing: 12) {
                    addChoreForm

                    ForEach(store.state.chores) { chore in
                        ChoreRow(chore: chore)
                    }
                }
            }

            Panel(title: "Family", subtitle: "At a glance", systemImage: "person.3.fill") {
                LazyVGrid(columns: adaptiveColumns(minimum: 140), spacing: 10) {
                    ForEach(store.family) { member in
                        FamilyMemberCard(member: member)
                    }
                }
            }

            Panel(title: "Bulletin", subtitle: "House notes", systemImage: "message.fill") {
                VStack(spacing: 12) {
                    addNoteForm

                    ForEach(store.state.notes) { note in
                        NoteCard(note: note)
                    }
                }
            }

            Panel(title: "Meals", subtitle: "Dinner plan", systemImage: "fork.knife") {
                VStack(spacing: 10) {
                    ForEach(store.meals) { meal in
                        MealRow(meal: meal)
                    }
                }
            }

            Panel(title: "Grocery list", subtitle: "Kitchen", systemImage: "cart.fill") {
                VStack(spacing: 12) {
                    addGroceryForm

                    ForEach(store.state.groceries) { item in
                        GroceryRow(item: item)
                    }
                }
            }

            Panel(title: "Household budget", subtitle: "Monthly", systemImage: "creditcard.fill") {
                VStack(alignment: .leading, spacing: 14) {
                    budgetSummary
                    addBudgetSpendForm

                    ForEach(store.state.budgetCategories) { category in
                        BudgetCategoryRow(category: category)
                    }
                }
            }
        }
    }

    private var addChoreForm: some View {
        HStack(spacing: 10) {
            TextField("Add a chore", text: $newChore)
                .textFieldStyle(.roundedBorder)

            Picker("Owner", selection: $selectedOwner) {
                ForEach(store.family) { member in
                    Text(member.name).tag(member.name)
                }
            }
            .frame(maxWidth: 130)

            Button {
                store.addChore(task: newChore, owner: selectedOwner)
                newChore = ""
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var addNoteForm: some View {
        HStack(spacing: 10) {
            TextField("Leave a note", text: $newNote)
                .textFieldStyle(.roundedBorder)

            Button("Add", systemImage: "plus.circle") {
                store.addNote(newNote)
                newNote = ""
            }
            .buttonStyle(.bordered)
        }
    }

    private var addGroceryForm: some View {
        HStack(spacing: 10) {
            TextField("Add grocery item", text: $newGroceryItem)
                .textFieldStyle(.roundedBorder)

            TextField("Category", text: $newGroceryCategory)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 120)

            Button {
                store.addGroceryItem(name: newGroceryItem, category: newGroceryCategory)
                newGroceryItem = ""
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var budgetSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(currency(store.monthlyBudgetSpent))
                        .font(.title2.weight(.bold))
                    Text("spent of \(currency(store.monthlyBudgetLimit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(currency(store.monthlyBudgetRemaining))
                    .font(.headline)
                    .foregroundStyle(store.monthlyBudgetRemaining >= 0 ? Color.wattsonTeal : .red)
            }

            ProgressView(value: store.monthlyBudgetProgress)
                .tint(store.monthlyBudgetRemaining >= 0 ? Color.wattsonTeal : .red)
        }
        .padding(14)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var addBudgetSpendForm: some View {
        HStack(spacing: 10) {
            Picker("Category", selection: $selectedBudgetCategory) {
                ForEach(store.state.budgetCategories) { category in
                    Text(category.name).tag(category.name)
                }
            }
            .frame(maxWidth: 150)

            TextField("Amount", text: $budgetSpendAmount)
                .textFieldStyle(.roundedBorder)

            Button("Add", systemImage: "plus.circle") {
                guard
                    let category = store.state.budgetCategories.first(where: { $0.name == selectedBudgetCategory }),
                    let amount = Double(budgetSpendAmount.trimmingCharacters(in: .whitespacesAndNewlines))
                else {
                    return
                }

                store.addBudgetSpend(category: category, amount: amount)
                budgetSpendAmount = ""
            }
            .buttonStyle(.bordered)
        }
    }

    private func adaptiveColumns(minimum: CGFloat) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum), spacing: 16, alignment: .top)]
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

private struct StatusTile: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(Color.wattsonTeal)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08))
        )
    }
}

private struct Panel<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subtitle.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.title3.weight(.bold))
                }

                Spacer()

                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.wattsonTeal)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(18)
        .background(.background.opacity(0.92), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08))
        )
    }
}

private struct ScheduleRow: View {
    let item: ScheduleItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(item.time)
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.wattsonInk)
                .frame(width: 56, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text("\(item.owner) - \(item.place)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct WeatherForecastView: View {
    let days: [WeatherDay]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 116), spacing: 10)], spacing: 10) {
            ForEach(days) { day in
                WeatherDayCard(day: day)
            }
        }
    }
}

private struct WeatherDayCard: View {
    let day: WeatherDay

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day.day)
                    .font(.headline)
                Spacer()
                Image(systemName: day.systemImage)
                    .foregroundStyle(Color.wattsonGold)
            }

            Text("\(day.high) deg")
                .font(.title2.weight(.bold))
            Text("Low \(day.low) deg")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(day.precipitationChance)% rain")
                .font(.caption.weight(.semibold))
                .foregroundStyle(day.precipitationChance > 50 ? .blue : .secondary)
            Text(day.condition)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct CalendarEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Text(event.day)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                Text(event.date)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(width: 58, height: 50)
            .background(Color.wattsonTeal, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text("\(event.time) - \(event.location)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(event.owner)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.wattsonPurple)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ChoreRow: View {
    @EnvironmentObject private var store: HouseholdStore
    let chore: Chore

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.toggleChore(chore)
            } label: {
                Image(systemName: chore.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.wattsonTeal)

            VStack(alignment: .leading, spacing: 4) {
                Text(chore.task)
                    .font(.headline)
                    .strikethrough(chore.isDone)
                Text("\(chore.owner) - \(chore.due)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                store.deleteChore(chore)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(chore.isDone ? Color.wattsonDone : Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct GroceryRow: View {
    @EnvironmentObject private var store: HouseholdStore
    let item: GroceryItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.toggleGroceryItem(item)
            } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.wattsonTeal)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isChecked)
                Text(item.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                store.deleteGroceryItem(item)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(item.isChecked ? Color.wattsonDone : Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct BudgetCategoryRow: View {
    let category: BudgetCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.name)
                    .font(.headline)
                Spacer()
                Text("\(currency(category.spent)) / \(currency(category.monthlyLimit))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: category.progress)
                .tint(category.remaining >= 0 ? Color.wattsonTeal : .red)

            Text("\(currency(category.remaining)) remaining")
                .font(.caption)
                .foregroundStyle(category.remaining >= 0 ? Color.secondary : Color.red)
        }
        .padding(14)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

private struct FamilyMemberCard: View {
    let member: FamilyMember

    var body: some View {
        HStack(spacing: 10) {
            Text(member.initials)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(member.color, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(member.name)
                    .font(.headline)
                Text(member.role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct NoteCard: View {
    let note: HouseholdNote

    var toneColor: Color {
        switch note.tone {
        case .info:
            return .blue
        case .alert:
            return .orange
        case .success:
            return Color.wattsonTeal
        }
    }

    var body: some View {
        Text(note.text)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(toneColor)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
    }
}

private struct MealRow: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            Text(meal.day)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 38)
                .background(Color.wattsonPurple, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title)
                    .font(.headline)
                Text(meal.tag)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.wattsonSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private extension Color {
    static let wattsonBackground = Color(red: 0.965, green: 0.953, blue: 0.925)
    static let wattsonSurface = Color(red: 0.984, green: 0.980, blue: 0.965)
    static let wattsonDone = Color(red: 0.933, green: 0.973, blue: 0.949)
    static let wattsonInk = Color(red: 0.114, green: 0.145, blue: 0.173)
    static let wattsonTeal = Color(red: 0.059, green: 0.463, blue: 0.431)
    static let wattsonPurple = Color(red: 0.486, green: 0.227, blue: 0.929)
    static let wattsonGold = Color(red: 0.855, green: 0.541, blue: 0.102)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HouseholdStore())
    }
}

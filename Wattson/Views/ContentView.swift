import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: HouseholdStore
    @State private var selectedOwner = "Dana"
    @State private var newChore = ""
    @State private var newNote = ""

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

            Text("Family command center")
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
        }
    }

    private var dashboard: some View {
        LazyVGrid(columns: adaptiveColumns(minimum: 320), spacing: 16) {
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

    private func adaptiveColumns(minimum: CGFloat) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum), spacing: 16, alignment: .top)]
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HouseholdStore())
    }
}

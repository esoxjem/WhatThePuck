import SwiftUI
import SwiftData

struct ShotListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Shot.date, order: .reverse) private var shots: [Shot]
    @Query(sort: \Bean.createdAt, order: .reverse) private var beans: [Bean]

    @State private var showingAddShotSheet = false
    @State private var showingAddBeanSheet = false
    @State private var shotToEdit: Shot?
    @State private var showFavoritesOnly = false
    @State private var selectedBeanFilter: Bean?

    var body: some View {
        NavigationStack {
            Group {
                if filteredShots.isEmpty {
                    emptyState
                } else {
                    shotsList
                }
            }
            .navigationTitle("WhatThePuck")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 16) {
                        Button {
                            showFavoritesOnly.toggle()
                        } label: {
                            Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                        }
                        .tint(showFavoritesOnly ? .yellow : .primary)

                        beanFilterMenu
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if beans.isEmpty {
                            showingAddBeanSheet = true
                        } else {
                            showingAddShotSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddShotSheet) {
                ShotFormView()
            }
            .sheet(isPresented: $showingAddBeanSheet) {
                BeanFormView(showFirstBeanHint: true)
            }
            .sheet(item: $shotToEdit) { shot in
                ShotFormView(shotToEdit: shot)
            }
        }
    }

    private var hasActiveFilters: Bool {
        showFavoritesOnly || selectedBeanFilter != nil
    }

    private var filteredShots: [Shot] {
        shots.filter { shot in
            let matchesFavorite = !showFavoritesOnly || shot.isFavorite
            let matchesBean = selectedBeanFilter == nil || shot.bean.id == selectedBeanFilter?.id
            return matchesFavorite && matchesBean
        }
    }

    private var beanFilterMenu: some View {
        Menu {
            Button {
                selectedBeanFilter = nil
            } label: {
                if selectedBeanFilter == nil {
                    Label("All Beans", systemImage: "checkmark")
                } else {
                    Text("All Beans")
                }
            }
            Divider()
            ForEach(beans) { bean in
                Button {
                    selectedBeanFilter = bean
                } label: {
                    if selectedBeanFilter?.id == bean.id {
                        Label(bean.displayName, systemImage: "checkmark")
                    } else {
                        Text(bean.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: selectedBeanFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
        .tint(selectedBeanFilter != nil ? .accentColor : .primary)
    }

    @ViewBuilder
    private var emptyState: some View {
        if hasActiveFilters {
            ContentUnavailableView(
                "No matching shots",
                systemImage: "line.3.horizontal.decrease.circle",
                description: Text(emptyStateFilterDescription)
            )
        } else {
            terminalForCurrentState
        }
    }

    @ViewBuilder
    private var terminalForCurrentState: some View {
        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: beans,
            activeBean: beans.first
        )
        let message = MessageEngineProvider.shared.getMessage(context: context)
        let lines = message.components(separatedBy: "\n")
        TerminalView(content: .contextualMessage(lines: lines))
            .id("contextual-\(shots.count)-\(beans.count)")
    }

    private var emptyStateFilterDescription: String {
        var filters: [String] = []
        if showFavoritesOnly { filters.append("favorites") }
        if let bean = selectedBeanFilter { filters.append(bean.displayName) }
        return "No shots match: \(filters.joined(separator: ", "))"
    }

    private var shotsList: some View {
        List {
            Section {
                terminalForCurrentState
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            ForEach(groupedByDate, id: \.0) { date, dayShots in
                Section(header: Text(formatDate(date))) {
                    ForEach(dayShots) { shot in
                        ShotRowView(shot: shot)
                            .contentShape(Rectangle())
                            .onTapGesture { shotToEdit = shot }
                            .swipeActions(edge: .leading) {
                                Button {
                                    shot.isFavorite.toggle()
                                } label: {
                                    Image(systemName: shot.isFavorite ? "star.slash" : "star.fill")
                                }
                                .tint(.yellow)
                            }
                    }
                    .onDelete { indexSet in
                        deleteShots(dayShots: dayShots, at: indexSet)
                    }
                }
            }
        }
    }

    private var groupedByDate: [(Date, [Shot])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredShots) { shot in
            calendar.startOfDay(for: shot.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }

    @MainActor
    private func deleteShots(dayShots: [Shot], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dayShots[index])
        }
    }
}

#Preview {
    ShotListView()
        .modelContainer(for: [Shot.self, Bean.self], inMemory: true)
}

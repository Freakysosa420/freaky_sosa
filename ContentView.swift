import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    // Live query — fetch all records; we sort/filter client-side for dynamic controls
    @Query private var records: [WorkspaceRecord]

    private enum SortKey: String, CaseIterable {
        case timestamp = "Timestamp"
        case title = "Title"
    }

    @State private var sortKey: SortKey = .timestamp
    @State private var sortAscending: Bool = false // default: timestamp descending

    @State private var searchText: String = ""
    @State private var showingAddSheet = false
    @State private var editingRecord: WorkspaceRecord? = nil

    private var filteredAndSortedRecords: [WorkspaceRecord] {
        var filtered: [WorkspaceRecord]
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filtered = records
        } else {
            filtered = records.filter { rec in
                rec.title.localizedCaseInsensitiveContains(query) ||
                rec.recordDescription.localizedCaseInsensitiveContains(query)
            }
        }

        let sorted = filtered.sorted { a, b in
            switch sortKey {
            case .timestamp:
                if sortAscending {
                    return a.timestamp < b.timestamp
                } else {
                    return a.timestamp > b.timestamp
                }
            case .title:
                if sortAscending {
                    return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
                } else {
                    return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedDescending
                }
            }
        }
        return sorted
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAndSortedRecords, id: \.id) { record in
                    Button {
                        editingRecord = record
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.title)
                                    .font(.headline)
                                Text(record.recordDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(record.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Image(systemName: record.isFlagged ? "flag.fill" : "flag")
                                    .foregroundColor(record.isFlagged ? .accentColor : .secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            delete(record)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleFlag(record)
                        } label: {
                            Label(record.isFlagged ? "Unflag" : "Flag", systemImage: "flag")
                        }
                        .tint(.orange)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Workspace Records")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort by", selection: $sortKey) {
                            ForEach(SortKey.allCases, id: \.self) { key in
                                Text(key.rawValue).tag(key)
                            }
                        }

                        Button {
                            sortAscending.toggle()
                        } label: {
                            Label(sortAscending ? "Ascending" : "Descending", systemImage: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .sheet(isPresented: $showingAddSheet) {
                RecordFormView { title, description, isFlagged, timestamp in
                    addRecord(title: title, description: description, isFlagged: isFlagged, timestamp: timestamp)
                    showingAddSheet = false
                } onCancel: {
                    showingAddSheet = false
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $editingRecord) { record in
                RecordFormView(record: record) { title, description, isFlagged, timestamp in
                    update(record: record, title: title, description: description, isFlagged: isFlagged, timestamp: timestamp)
                    editingRecord = nil
                } onCancel: {
                    editingRecord = nil
                }
                .presentationDetents([.medium, .large])
            }
            .task {
                // Seed sample data on first appearance
                await MainActor.run {
                    SampleDataSeeder.seedIfNeeded(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - CRUD actions

    private func addRecord(title: String, description: String, isFlagged: Bool, timestamp: Date) {
        let newRecord = WorkspaceRecord(title: title, recordDescription: description, isFlagged: isFlagged, timestamp: timestamp)
        modelContext.insert(newRecord)
        do {
            try modelContext.save()
        } catch {
            print("Failed saving new record: \(error)")
        }
    }

    private func update(record: WorkspaceRecord, title: String, description: String, isFlagged: Bool, timestamp: Date) {
        record.title = title
        record.recordDescription = description
        record.isFlagged = isFlagged
        record.timestamp = timestamp
        do {
            try modelContext.save()
        } catch {
            print("Failed saving updated record: \(error)")
        }
    }

    private func delete(_ record: WorkspaceRecord) {
        modelContext.delete(record)
        do {
            try modelContext.save()
        } catch {
            print("Failed deleting record: \(error)")
        }
    }

    private func toggleFlag(_ record: WorkspaceRecord) {
        record.isFlagged.toggle()
        do {
            try modelContext.save()
        } catch {
            print("Failed toggling flag: \(error)")
        }
    }
}

// RecordFormView remains the same as previously added in the project.

#Preview {
    ContentView()
        .modelContainer(for: [WorkspaceRecord.self], inMemory: true)
}

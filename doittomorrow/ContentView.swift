//
//  ContentView.swift
//  doittomorrow
//
//  Created by Emil Drahoš on 17.03.2026.
//

import SwiftUI
import SwiftData

enum DayTab: String, CaseIterable {
    case today = "Today"
    case tomorrow = "Tomorrow"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt) private var allItems: [TodoItem]

    @State private var selectedTab: DayTab = .today
    @State private var newTaskTitle = ""

    private var filteredItems: [TodoItem] {
        let isToday = selectedTab == .today
        return allItems
            .filter { $0.isToday == isToday }
            .sorted { !$0.isCompleted && $1.isCompleted }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Day", selection: $selectedTab) {
                    ForEach(DayTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                    ForEach(filteredItems) { item in
                        TaskRow(item: item, selectedTab: selectedTab) {
                            toggleComplete(item)
                        } onMove: {
                            moveTask(item)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)

                addTaskBar
            }
            .navigationTitle("Do It Tomorrow")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 12) {
            TextField("New task…", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addTask)

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(.bar)
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let item = TodoItem(title: trimmed, isToday: selectedTab == .today)
        modelContext.insert(item)
        newTaskTitle = ""
    }

    private func toggleComplete(_ item: TodoItem) {
        item.isCompleted.toggle()
    }

    private func moveTask(_ item: TodoItem) {
        item.isToday.toggle()
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredItems[index])
        }
    }
}

// MARK: - Task Row

struct TaskRow: View {
    let item: TodoItem
    let selectedTab: DayTab
    let onToggle: () -> Void
    let onMove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)

            Spacer()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                // Deletion handled by onDelete modifier
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                onMove()
            } label: {
                if selectedTab == .today {
                    Label("Tomorrow", systemImage: "arrow.right")
                } else {
                    Label("Today", systemImage: "arrow.left")
                }
            }
            .tint(.orange)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

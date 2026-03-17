//
//  doittomorrowApp.swift
//  doittomorrow
//
//  Created by Emil Drahoš on 17.03.2026.
//

import SwiftUI
import SwiftData

@main
struct doittomorrowApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: TodoItem.self)
            Self.rolloverTasksIfNeeded(context: modelContainer.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }

    /// Moves tomorrow's tasks to today when a new day begins.
    private static func rolloverTasksIfNeeded(context: ModelContext) {
        let defaults = UserDefaults.standard
        let lastOpenedKey = "lastOpenedDate"
        let today = Calendar.current.startOfDay(for: Date())

        if let lastOpened = defaults.object(forKey: lastOpenedKey) as? Date,
           Calendar.current.isDate(lastOpened, inSameDayAs: today) {
            return
        }

        defaults.set(today, forKey: lastOpenedKey)

        let descriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { $0.isToday == false }
        )
        guard let tomorrowItems = try? context.fetch(descriptor) else { return }

        for item in tomorrowItems {
            item.isToday = true
        }
        try? context.save()
    }
}

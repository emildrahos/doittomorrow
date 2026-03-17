//
//  TodoItem.swift
//  doittomorrow
//
//  Created by Emil Drahoš on 17.03.2026.
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var isToday: Bool
    var createdAt: Date

    init(title: String, isToday: Bool = true) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.isToday = isToday
        self.createdAt = Date()
    }
}

import Foundation
import SwiftData

@Model
final class WorkspaceRecord {
    var id: UUID
    var timestamp: Date
    var title: String
    var recordDescription: String
    var isFlagged: Bool

    init(id: UUID = UUID(), timestamp: Date = Date(), title: String, recordDescription: String = "", isFlagged: Bool = false) {
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.recordDescription = recordDescription
        self.isFlagged = isFlagged
    }
}

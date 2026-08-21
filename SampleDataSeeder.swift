import Foundation
import SwiftData

@MainActor
public struct SampleDataSeeder {
    public static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<WorkspaceRecord>()
        do {
            let count = try modelContext.fetchCount(descriptor)
            if count == 0 {
                #if DEBUG
                let samples: [WorkspaceRecord] = [
                    WorkspaceRecord(title: "Sosa XAI Core Boot", recordDescription: "Initialized local-first SwiftData container pipeline.", isFlagged: true),
                    WorkspaceRecord(title: "GitHub Actions CI/CD", recordDescription: "Verified swift.yml workflow runner successfully compiled code.", isFlagged: false),
                    WorkspaceRecord(title: "First Run: Demo Data", recordDescription: "Populated the app with demo logs for quick testing.", isFlagged: false),
                    WorkspaceRecord(title: "Flagged Issue: API Rate", recordDescription: "Simulated flagged log to test UI behavior.", isFlagged: true)
                ]
                for sample in samples {
                    modelContext.insert(sample)
                }
                try modelContext.save()
                #endif
            }
        } catch {
            print("Failed to seed sample data: \(error)")
        }
    }
}

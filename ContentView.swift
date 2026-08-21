import SwiftUI
import SwiftData

/// The primary SwiftUI interface and navigation flow for freaky_sosa.
public struct ContentView: View {
    @Environment(\.modelContext) private modelContext
    
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "cpu")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                
                Text("freaky_sosa Workspace")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Local-first SwiftUI interface integrated with SwiftData and Sosa XAI architecture.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationTitle("Dashboard")
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [], inMemory: true)
}

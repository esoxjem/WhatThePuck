import Foundation

enum CursorBlink {
    static func stream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task { @MainActor in
                var visible = true
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(for: .milliseconds(530))
                        visible.toggle()
                        continuation.yield(visible)
                    } catch {
                        break
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}

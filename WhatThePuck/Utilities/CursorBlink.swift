import Foundation

enum CursorBlink {
    static func stream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                var visible = true
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(530))
                    visible.toggle()
                    continuation.yield(visible)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

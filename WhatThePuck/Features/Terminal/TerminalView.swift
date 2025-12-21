import SwiftUI

enum TerminalContent {
    case onboarding(hasBeans: Bool)
    case beanContext(bean: Bean)

    var lines: [String] {
        switch self {
        case .onboarding(let hasBeans):
            return buildOnboardingLines(hasBeans: hasBeans)
        case .beanContext(let bean):
            return buildBeanContextLines(for: bean)
        }
    }

    var characterDelay: TimeInterval {
        switch self {
        case .onboarding: return 0.06
        case .beanContext: return 0.04
        }
    }

    private func buildOnboardingLines(hasBeans: Bool) -> [String] {
        var messages = [
            "Welcome to espresso hell.",
            "Let's add your coffee beans."
        ]
        if hasBeans {
            messages.append("We're ready to pull the first shot.")
        }
        return messages
    }

    private func buildBeanContextLines(for bean: Bean) -> [String] {
        var messages = ["\(bean.displayName) loaded."]
        messages.append(roastInfoLine(for: bean))
        messages.append("Pull your first shot.")
        return messages
    }

    private func roastInfoLine(for bean: Bean) -> String {
        if let roastAge = bean.roastAgeDescription {
            return roastAge
        }
        return "\(bean.roastLevel.rawValue) roast."
    }
}

struct TerminalView: View {
    let content: TerminalContent

    @State private var displayedLines: [String]
    @State private var currentLineIndex = 0
    @State private var characterIndex = 0
    @State private var phase = TerminalPhase.typing
    @State private var cursorVisible = true

    init(content: TerminalContent) {
        self.content = content
        self._displayedLines = State(initialValue: Array(repeating: "", count: content.lines.count))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(0..<visibleLineCount, id: \.self) { index in
                terminalLine(
                    text: displayedLines[index],
                    showCursor: shouldShowCursor(at: index)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .font(.system(.subheadline, design: .monospaced))
        .task { await runCursorBlink() }
        .task { await runTypewriterAnimation() }
        .onChange(of: content.lines.count) { oldCount, newCount in
            handleLineCountChange(from: oldCount, to: newCount)
        }
    }

    private func handleLineCountChange(from oldCount: Int, to newCount: Int) {
        guard newCount > oldCount else { return }
        displayedLines.append(contentsOf: Array(repeating: "", count: newCount - oldCount))
        guard phase == .complete else { return }
        phase = .pauseBetweenLines
    }

    private var visibleLineCount: Int {
        min(currentLineIndex + 1, content.lines.count)
    }

    private func shouldShowCursor(at index: Int) -> Bool {
        index == currentLineIndex
    }

    private func terminalLine(text: String, showCursor: Bool) -> some View {
        HStack(spacing: 0) {
            Text(text)
            if showCursor {
                Text("█")
                    .opacity(cursorVisible ? 1 : 0)
            }
        }
    }

    @MainActor
    private func runCursorBlink() async {
        for await visible in CursorBlink.stream() {
            cursorVisible = visible
        }
    }

    @MainActor
    private func runTypewriterAnimation() async {
        while !Task.isCancelled {
            guard phase != .complete else {
                try? await Task.sleep(for: .milliseconds(100))
                continue
            }
            let sleepDuration = durationForCurrentPhase()
            try? await Task.sleep(for: sleepDuration)
            advanceAnimation()
        }
    }

    private func durationForCurrentPhase() -> Duration {
        switch phase {
        case .typing:
            return .milliseconds(Int(content.characterDelay * 1000))
        case .pauseBetweenLines:
            return .seconds(1)
        case .complete:
            return .zero
        }
    }

    private func advanceAnimation() {
        switch phase {
        case .typing:
            typeNextCharacter()
        case .pauseBetweenLines:
            advanceToNextLine()
        case .complete:
            return
        }
    }

    private func typeNextCharacter() {
        let currentLine = content.lines[currentLineIndex]
        guard characterIndex < currentLine.count else {
            finishCurrentLine()
            return
        }
        let index = currentLine.index(currentLine.startIndex, offsetBy: characterIndex)
        displayedLines[currentLineIndex].append(currentLine[index])
        characterIndex += 1
    }

    private func finishCurrentLine() {
        if currentLineIndex < content.lines.count - 1 {
            phase = .pauseBetweenLines
            characterIndex = 0
        } else {
            phase = .complete
        }
    }

    private func advanceToNextLine() {
        currentLineIndex += 1
        phase = .typing
    }
}

private enum TerminalPhase {
    case typing
    case pauseBetweenLines
    case complete
}

#Preview("Onboarding - No Beans") {
    TerminalView(content: .onboarding(hasBeans: false))
}

#Preview("Onboarding - Has Beans") {
    TerminalView(content: .onboarding(hasBeans: true))
}

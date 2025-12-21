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
    @State private var animationTimer: Timer?
    @State private var cursorTimer: Timer?

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
        .onAppear {
            startCursorBlink()
            startAnimation()
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: content.lines.count) { oldCount, newCount in
            handleLineCountChange(from: oldCount, to: newCount)
        }
    }

    private func handleLineCountChange(from oldCount: Int, to newCount: Int) {
        guard newCount > oldCount else { return }
        displayedLines.append(contentsOf: Array(repeating: "", count: newCount - oldCount))
        guard phase == .complete else { return }
        phase = .pauseBetweenLines
        scheduleNextCharacter()
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

    private func startCursorBlink() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.53, repeats: true) { _ in
            cursorVisible.toggle()
        }
    }

    private func startAnimation() {
        scheduleNextCharacter()
    }

    private func scheduleNextCharacter() {
        let interval = intervalForCurrentPhase()
        animationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            advanceAnimation()
        }
    }

    private func intervalForCurrentPhase() -> TimeInterval {
        switch phase {
        case .typing:
            return content.characterDelay
        case .pauseBetweenLines:
            return 1.0
        case .complete:
            return 0
        }
    }

    private func advanceAnimation() {
        switch phase {
        case .typing:
            typeCurrentLine()
        case .pauseBetweenLines:
            moveToNextLine()
        case .complete:
            return
        }
    }

    private func typeCurrentLine() {
        let currentLine = content.lines[currentLineIndex]
        if characterIndex < currentLine.count {
            let index = currentLine.index(currentLine.startIndex, offsetBy: characterIndex)
            displayedLines[currentLineIndex].append(currentLine[index])
            characterIndex += 1
            scheduleNextCharacter()
        } else {
            finishCurrentLine()
        }
    }

    private func finishCurrentLine() {
        if currentLineIndex < content.lines.count - 1 {
            phase = .pauseBetweenLines
            characterIndex = 0
            scheduleNextCharacter()
        } else {
            phase = .complete
        }
    }

    private func moveToNextLine() {
        currentLineIndex += 1
        phase = .typing
        scheduleNextCharacter()
    }

    private func stopTimers() {
        animationTimer?.invalidate()
        animationTimer = nil
        cursorTimer?.invalidate()
        cursorTimer = nil
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

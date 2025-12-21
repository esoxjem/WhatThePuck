import SwiftUI
import SwiftData

struct TimerView: View {
    @State private var elapsedTenths: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var showingSaveSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                timerDisplay

                controlButtons

                Spacer()
            }
            .navigationTitle("Timer")
            .sheet(isPresented: $showingSaveSheet) {
                ShotFormView(prefillTimeSeconds: elapsedTenths)
            }
        }
    }

    private var timerDisplay: some View {
        Text(formattedTime)
            .font(.system(size: 80, weight: .light, design: .monospaced))
            .contentTransition(.numericText())
    }

    private var formattedTime: String {
        let seconds = elapsedTenths / 10
        let tenths = elapsedTenths % 10
        return String(format: "%02d.%d", seconds, tenths)
    }

    private var controlButtons: some View {
        HStack(spacing: 40) {
            if !isRunning && elapsedTenths > 0 {
                resetButton
            }

            startStopButton

            if !isRunning && elapsedTenths > 0 {
                saveButton
            }
        }
    }

    private var startStopButton: some View {
        Button {
            toggleTimer()
        } label: {
            Image(systemName: isRunning ? "stop.fill" : "play.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(isRunning ? Color.red : Color.green)
                .clipShape(Circle())
        }
    }

    private var resetButton: some View {
        Button {
            resetTimer()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 60, height: 60)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        }
    }

    private var saveButton: some View {
        Button {
            showingSaveSheet = true
        } label: {
            Image(systemName: "square.and.arrow.down")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }

    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTenths += 1
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        elapsedTenths = 0
    }
}

#Preview {
    TimerView()
        .modelContainer(for: Shot.self, inMemory: true)
}

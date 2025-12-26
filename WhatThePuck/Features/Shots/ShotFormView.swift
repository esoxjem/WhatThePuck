import SwiftUI
import SwiftData

struct ShotFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Bean.createdAt, order: .reverse) private var beans: [Bean]
    @AppStorage("lastSelectedBeanID") private var lastSelectedBeanID: String = ""
    @AppStorage("lastGrindSetting") private var lastGrindSetting: Int = 15

    var prefillTimeSeconds: Int?
    var shotToEditID: PersistentIdentifier?

    private var shotToEdit: Shot? {
        guard let id = shotToEditID else { return nil }
        return modelContext.model(for: id) as? Shot
    }

    @State private var selectedBean: Bean?
    @State private var doseGrams: Double = 18.0
    @State private var yieldGrams: Double = 36.0
    @State private var timeInSeconds: Double = 28.0
    @State private var grindSetting: Int = 15
    @State private var notes: String = ""
    @State private var rating: ShotRating = .good

    private var isEditing: Bool { shotToEdit != nil }
    private var navigationTitle: String { isEditing ? "Edit Shot" : "Log Shot" }

    var body: some View {
        NavigationStack {
            Form {
                beanSection

                Section("Dose & Yield") {
                    HStack {
                        Text("Dose")
                        Spacer()
                        TextField("g", value: $doseGrams, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Yield")
                        Spacer()
                        TextField("g", value: $yieldGrams, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Ratio")
                        Spacer()
                        Text(ratioDisplay)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Extraction") {
                    HStack {
                        Text("Time")
                        Spacer()
                        TextField("sec", value: $timeInSeconds, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("s")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Grind Setting")
                        Spacer()
                        TextField("#", value: $grindSetting, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }

                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(ShotRating.allCases, id: \.self) { ratingOption in
                            Text(ratingOption.displayName).tag(ratingOption)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextField("How was it?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveShot() }
                        .disabled(selectedBean == nil)
                }
            }
            .onAppear {
                if let shot = shotToEdit {
                    populateFieldsFromShot(shot)
                } else {
                    if let prefillTenths = prefillTimeSeconds {
                        timeInSeconds = Double(prefillTenths) / 10.0
                    }
                    grindSetting = lastGrindSetting
                    preselectBean()
                }
            }
        }
    }

    @ViewBuilder
    private var beanSection: some View {
        Section("Bean") {
            if beans.isEmpty {
                Text("Add a bean first in the Beans tab")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Select Bean", selection: $selectedBean) {
                    Text("Select a bean").tag(nil as Bean?)
                    ForEach(beans) { bean in
                        Text(bean.displayName).tag(bean as Bean?)
                    }
                }
            }
        }
    }

    private var ratioDisplay: String {
        guard doseGrams > 0 else { return "—" }
        let ratio = yieldGrams / doseGrams
        return String(format: "1:%.1f", ratio)
    }

    private func preselectBean() {
        if beans.count == 1 {
            selectedBean = beans.first
            return
        }

        guard !lastSelectedBeanID.isEmpty else { return }
        selectedBean = beans.first { $0.displayName == lastSelectedBeanID }
    }

    private func populateFieldsFromShot(_ shot: Shot) {
        selectedBean = beans.first { $0.id == shot.bean.id }
        doseGrams = shot.doseGrams
        yieldGrams = shot.yieldGrams
        timeInSeconds = Double(shot.timeSeconds) / 10.0
        grindSetting = shot.grindSetting
        notes = shot.notes
        rating = shot.rating ?? .good
    }

    @MainActor
    private func saveShot() {
        guard let bean = selectedBean else { return }
        lastSelectedBeanID = bean.displayName
        lastGrindSetting = grindSetting
        let timeAsTenths = Int(timeInSeconds * 10)

        if let existingShot = shotToEdit {
            existingShot.doseGrams = doseGrams
            existingShot.yieldGrams = yieldGrams
            existingShot.timeSeconds = timeAsTenths
            existingShot.grindSetting = grindSetting
            existingShot.notes = notes
            existingShot.bean = bean
            existingShot.rating = rating
        } else {
            let shot = Shot(
                doseGrams: doseGrams,
                yieldGrams: yieldGrams,
                timeSeconds: timeAsTenths,
                grindSetting: grindSetting,
                notes: notes,
                bean: bean,
                rating: rating
            )
            modelContext.insert(shot)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    ShotFormView()
        .modelContainer(for: [Shot.self, Bean.self], inMemory: true)
}

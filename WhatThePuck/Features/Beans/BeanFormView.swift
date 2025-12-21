import SwiftUI
import SwiftData

struct BeanFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var beanToEdit: Bean?
    var showFirstBeanHint: Bool = false

    @FocusState private var isNameFieldFocused: Bool
    @State private var name: String = ""
    @State private var roaster: String = ""
    @State private var roastLevel: RoastLevel = .medium
    @State private var roastDate: Date = .now
    @State private var hasRoastDate: Bool = false

    private var isEditing: Bool { beanToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                if showFirstBeanHint {
                    firstBeanHintSection
                }
                beanInfoSection
                roastDateSection
            }
            .navigationTitle(isEditing ? "Edit Bean" : "Add Bean")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveBean() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                populateFieldsIfEditing()
            }
        }
    }

    private var firstBeanHintSection: some View {
        Section {
            Label("Let's add your coffee beans first", systemImage: "info.circle")
                .foregroundStyle(.secondary)
        }
    }

    private var beanInfoSection: some View {
        Section("Bean Info") {
            TextField("Bean Name", text: $name)
                .focused($isNameFieldFocused)

            TextField("Roaster (optional)", text: $roaster)

            Picker("Roast Level", selection: $roastLevel) {
                ForEach(RoastLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
        }
    }

    private var roastDateSection: some View {
        Section("Roast Date") {
            Toggle("Track Roast Date", isOn: $hasRoastDate)

            if hasRoastDate {
                DatePicker("Roasted On", selection: $roastDate, displayedComponents: .date)
            }
        }
    }

    private func populateFieldsIfEditing() {
        if let bean = beanToEdit {
            name = bean.name
            roaster = bean.roaster
            roastLevel = bean.roastLevel
            hasRoastDate = bean.roastDate != nil
            roastDate = bean.roastDate ?? .now
        } else {
            isNameFieldFocused = true
        }
    }

    private func saveBean() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedRoaster = roaster.trimmingCharacters(in: .whitespaces)

        if let bean = beanToEdit {
            bean.name = trimmedName
            bean.roaster = trimmedRoaster
            bean.roastLevel = roastLevel
            bean.roastDate = hasRoastDate ? roastDate : nil
        } else {
            let bean = Bean(
                name: trimmedName,
                roaster: trimmedRoaster,
                roastLevel: roastLevel,
                roastDate: hasRoastDate ? roastDate : nil
            )
            modelContext.insert(bean)
        }

        do {
            try modelContext.save()
            hasCompletedOnboarding = true
            dismiss()
        } catch {
            print("Failed to save bean: \(error)")
        }
    }
}

#Preview("Add Bean") {
    BeanFormView()
        .modelContainer(for: [Shot.self, Bean.self], inMemory: true)
}

#Preview("Add First Bean") {
    BeanFormView(showFirstBeanHint: true)
        .modelContainer(for: [Shot.self, Bean.self], inMemory: true)
}

import SwiftUI
import SwiftData

struct BeanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bean.createdAt, order: .reverse) private var beans: [Bean]

    @State private var showingAddSheet = false
    @State private var beanToEdit: Bean?

    var body: some View {
        NavigationStack {
            Group {
                if beans.isEmpty {
                    emptyState
                } else {
                    beansList
                }
            }
            .navigationTitle("Beans")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                BeanFormView()
            }
            .sheet(item: $beanToEdit) { bean in
                BeanFormView(beanToEdit: bean)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No beans yet",
            systemImage: "leaf",
            description: Text("Add your first coffee bean to get started")
        )
    }

    private var beansList: some View {
        List {
            ForEach(beans) { bean in
                BeanRowView(bean: bean)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        beanToEdit = bean
                    }
            }
            .onDelete(perform: deleteBeans)
        }
    }

    private func deleteBeans(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(beans[index])
        }
    }
}

#Preview {
    BeanListView()
        .modelContainer(for: [Shot.self, Bean.self], inMemory: true)
}

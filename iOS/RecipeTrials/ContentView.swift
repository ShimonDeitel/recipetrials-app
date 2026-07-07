import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showAddSheet = false
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var editingItem: Attempt?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                            showAddSheet = false
                        } label: {
                            row(for: item)
                        }
                        .listRowBackground(Theme.card)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .accessibilityIdentifier("itemList")
            }
            .navigationTitle("Recipe Trials")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchaseManager.isPro) {
                            editingItem = Attempt()
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                if let item = editingItem {
                    EditorSheet(item: item, isNew: true)
                }
            }
            .sheet(isPresented: Binding(
                get: { editingItem != nil && !showAddSheet },
                set: { newValue in if !newValue { editingItem = nil } }
            )) {
                if let item = editingItem {
                    EditorSheet(item: item, isNew: false)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }

    @ViewBuilder
    private func row(for item: Attempt) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.recipe.isEmpty ? "Untitled" : item.recipe)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textPrimary)
            Text(item.createdAt, style: .date)
                .font(Theme.labelFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct EditorSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State var draft: Attempt
    let isNew: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                    TextField("Recipe", text: $draft.recipe)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("field_recipe")
                    TextField("Source", text: $draft.source)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("field_source")
                    Stepper("Rating: \(draft.rating)", value: $draft.rating, in: 0...5)
                        .accessibilityIdentifier("field_rating")
                    TextField("Notes", text: $draft.notes)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("field_notes")
                    }
                    .padding()
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            .navigationTitle(isNew ? "Add Attempt" : "Edit Attempt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isNew {
                            store.add(draft)
                        } else {
                            store.update(draft)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}

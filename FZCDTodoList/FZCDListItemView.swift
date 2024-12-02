//
//  FZCDListItemView.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import SwiftUI

struct FZCDListItemView: View {
    @ObservedObject var list: FZCDListModel
    @StateObject private var itemViewModel = FZCDItemViewModel(context: PersistenceController.shared.container.viewContext)

    @State private var newItemName: String = ""
    @State private var isEditing: Bool = false

    var body: some View {
        VStack {
            List {
                ForEach(itemViewModel.items) { item in
                    HStack {
                        Button(action: {
                            itemViewModel.toggleCompletion(for: item, in: list)
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)
                        }
                        Text(item.name)
                            .strikethrough(item.isCompleted, color: .gray)
                            .foregroundColor(item.isCompleted ? .gray : .primary)
                        Spacer()
                    }
                }
                .onDelete(perform: deleteItem)
                .onMove(perform: moveItem)
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isEditing.toggle() }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .navigationTitle(list.name)
        .onAppear {
            itemViewModel.fetchItems(for: list)
        }
        .sheet(isPresented: $isEditing) {
            VStack {
                Text("Add New Item")
                    .font(.headline)
                    .padding()

                TextField("Item name", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    addItem()
                }) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Functions

    /// Adds a new item to the list
    private func addItem() {
        guard !newItemName.isEmpty else { return }

        itemViewModel.addItem(to: list, name: newItemName)

        // Reset input
        newItemName = ""
        isEditing = false
    }

    /// Deletes an item from the list
    private func deleteItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = itemViewModel.items[index]
            itemViewModel.deleteItem(item, from: list)
        }
    }

    /// Moves an item within the list
    private func moveItem(from source: IndexSet, to destination: Int) {
        itemViewModel.items.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    let sampleItems = [
        FZCDItemModel(id: UUID(), name: "Buy milk", isCompleted: false),
        FZCDItemModel(id: UUID(), name: "Call the doctor", isCompleted: true),
        FZCDItemModel(id: UUID(), name: "Finish homework", isCompleted: false)
    ]
    let sampleList = FZCDListModel(id: UUID(), name: "Personal Tasks", items: sampleItems)
    return FZCDListItemView(list: sampleList)
}

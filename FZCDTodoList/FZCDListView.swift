//
//  FZCDListView.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import SwiftUI

struct FZCDListView: View {
    @StateObject private var listViewModel = FZCDListViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var newListName: String = ""
    @State private var showAddListDialog: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(listViewModel.lists) { list in
                        NavigationLink(destination: FZCDListItemView(list: list)) {
                            Text(list.name)
                        }
                    }
                    .onDelete(perform: deleteList)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddListDialog = true }) {
                            Label("Add List", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Todo Lists")
        }
        .sheet(isPresented: $showAddListDialog) {
            VStack {
                Text("Add New List")
                    .font(.headline)
                    .padding()

                TextField("List name", text: $newListName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    addList()
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

    /// Adds a new list
    private func addList() {
        guard !newListName.isEmpty else { return }

        listViewModel.addList(name: newListName)

        // Reset input
        newListName = ""
        showAddListDialog = false
    }

    /// Deletes a list
    private func deleteList(at offsets: IndexSet) {
        offsets.forEach { index in
            let list = listViewModel.lists[index]
            listViewModel.deleteList(list: list)
        }
    }
}

#Preview {
    FZCDListView()
}

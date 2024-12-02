//
//  FZCDItemViewModel.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import SwiftUI
import CoreData

class FZCDItemViewModel: ObservableObject {
    @Published var items: [FZCDItemModel] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch Items for a List
    /// Fetches all items for a specific list and updates the `items` array
    func fetchItems(for list: FZCDListModel) {
        guard let listEntity = fetchListEntity(by: list.id) else { return }
        guard let itemEntities = listEntity.items as? Set<ItemEntity> else { return }

        items = itemEntities.map { entity in
            FZCDItemModel(
                id: entity.id ?? UUID(),
                name: entity.name ?? "",
                isCompleted: entity.isCompleted
            )
        }.sorted { $0.name < $1.name } // Sort alphabetically for display
    }

    // MARK: - Add Item
    /// Adds a new item to the specified list
    func addItem(to list: FZCDListModel, name: String) {
        guard let listEntity = fetchListEntity(by: list.id) else { return }

        let newItemEntity = PersistenceController.shared.addItem(to: listEntity, name: name)
        if let newItemEntity = newItemEntity {
            let newItem = FZCDItemModel(
                id: newItemEntity.id ?? UUID(),
                name: newItemEntity.name ?? "",
                isCompleted: newItemEntity.isCompleted
            )
            items.append(newItem)
        }
    }

    // MARK: - Delete Item
    /// Deletes an item from the specified list
    func deleteItem(_ item: FZCDItemModel, from list: FZCDListModel) {
        guard let listEntity = fetchListEntity(by: list.id),
              let itemEntity = fetchItemEntity(by: item.id, from: listEntity) else { return }

        PersistenceController.shared.deleteItem(item: itemEntity)
        items.removeAll { $0.id == item.id }
    }

    // MARK: - Toggle Completion
    /// Toggles the completion status of an item
    func toggleCompletion(for item: FZCDItemModel, in list: FZCDListModel) {
        guard let listEntity = fetchListEntity(by: list.id),
              let itemEntity = fetchItemEntity(by: item.id, from: listEntity) else { return }

        PersistenceController.shared.toggleCompletion(for: itemEntity)

        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }

    // MARK: - Fetch Helper Methods
    /// Fetches a `ListEntity` by its UUID
    private func fetchListEntity(by id: UUID) -> ListEntity? {
        let fetchRequest: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching list entity: \(error.localizedDescription)")
            return nil
        }
    }

    /// Fetches an `ItemEntity` by its UUID from a specific list
    private func fetchItemEntity(by id: UUID, from listEntity: ListEntity) -> ItemEntity? {
        guard let items = listEntity.items as? Set<ItemEntity> else { return nil }
        return items.first { $0.id == id }
    }
}


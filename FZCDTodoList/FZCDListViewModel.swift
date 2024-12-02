//
//  FZCDListViewModel.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import SwiftUI
import CoreData

class FZCDListViewModel: ObservableObject {
    @Published var lists: [FZCDListModel] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        PersistenceController.shared.printCoreDataPath()
        fetchLists()
    }

    // MARK: - Fetch Lists
    func fetchLists() {
        let fetchRequest: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        do {
            let listEntities = try context.fetch(fetchRequest)
            self.lists = listEntities.map { entity in
                FZCDListModel(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "Untitled List",
                    items: entity.items?.compactMap { itemEntity in
                        guard let item = itemEntity as? ItemEntity else { return nil }
                        return FZCDItemModel(
                            id: item.id ?? UUID(),
                            name: item.name ?? "",
                            isCompleted: item.isCompleted
                        )
                    } ?? []
                )
            }
        } catch {
            print("Error fetching lists: \(error.localizedDescription)")
        }
    }

    // MARK: - Add List
    func addList(name: String) {
        let newListEntity = PersistenceController.shared.createList(name: name)
        if let entity = newListEntity {
            let newList = FZCDListModel(
                id: entity.id ?? UUID(),
                name: entity.name ?? "",
                items: []
            )
            lists.append(newList)
        }
    }

    // MARK: - Delete List
    func deleteList(list: FZCDListModel) {
        if let listEntity = fetchListEntity(by: list.id) {
            PersistenceController.shared.deleteList(list: listEntity)
            lists.removeAll { $0.id == list.id }
        }
    }

    // MARK: - Fetch List Entity
    private func fetchListEntity(by id: UUID) -> ListEntity? {
        let fetchRequest: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching list entity by ID: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Add Item to List
    func addItem(to list: FZCDListModel, name: String) {
        if let listEntity = fetchListEntity(by: list.id) {
            let newItemEntity = PersistenceController.shared.addItem(to: listEntity, name: name)
            if let newItemEntity = newItemEntity {
                let newItem = FZCDItemModel(
                    id: newItemEntity.id ?? UUID(),
                    name: newItemEntity.name ?? "",
                    isCompleted: newItemEntity.isCompleted
                )
                if let index = lists.firstIndex(where: { $0.id == list.id }) {
                    lists[index].items.append(newItem)
                }
            }
        }
    }

    // MARK: - Delete Item
    func deleteItem(_ item: FZCDItemModel, from list: FZCDListModel) {
        if let listEntity = fetchListEntity(by: list.id),
           let itemEntity = fetchItemEntity(by: item.id, from: listEntity) {
            PersistenceController.shared.deleteItem(item: itemEntity)
            if let index = lists.firstIndex(where: { $0.id == list.id }) {
                lists[index].items.removeAll { $0.id == item.id }
            }
        }
    }

    // MARK: - Fetch Item Entity
    private func fetchItemEntity(by id: UUID, from listEntity: ListEntity) -> ItemEntity? {
        guard let items = listEntity.items as? Set<ItemEntity> else { return nil }
        return items.first { $0.id == id }
    }

    // MARK: - Toggle Completion
    func toggleCompletion(for item: FZCDItemModel, in list: FZCDListModel) {
        if let listEntity = fetchListEntity(by: list.id),
           let itemEntity = fetchItemEntity(by: item.id, from: listEntity) {
            PersistenceController.shared.toggleCompletion(for: itemEntity)
            if let listIndex = lists.firstIndex(where: { $0.id == list.id }),
               let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) {
                lists[listIndex].items[itemIndex].isCompleted.toggle()
            }
        }
    }
}

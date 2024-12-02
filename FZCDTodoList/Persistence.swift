//
//  Persistence.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import CoreData

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Core Data Stack
    let container: NSPersistentContainer

    // Initialize the persistence container
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FZCDTodoList")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    /// Prints the file path for the Core Data SQLite database
    func printCoreDataPath() {
        if let storeDescription = container.persistentStoreDescriptions.first,
           let url = storeDescription.url {
            print("Core Data SQLite path: \(url.path)")
        } else {
            print("Core Data path not found.")
        }
    }

    // MARK: - CRUD Methods for Lists

    /// Create a new list
    func createList(name: String) -> ListEntity? {
        let context = container.viewContext
        let newList = ListEntity(context: context)
        newList.id = UUID()
        newList.name = name

        do {
            try context.save()
            return newList
        } catch {
            print("Failed to create list: \(error.localizedDescription)")
            return nil
        }
    }

    /// Fetch all lists
    func fetchLists() -> [ListEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch lists: \(error.localizedDescription)")
            return []
        }
    }

    /// Delete a list
    func deleteList(list: ListEntity) {
        let context = container.viewContext
        context.delete(list)
        saveContext()
    }

    // MARK: - CRUD Methods for Items

    /// Add a new item to a specific list
    func addItem(to list: ListEntity, name: String) -> ItemEntity? {
        let context = container.viewContext
        let newItem = ItemEntity(context: context)
        newItem.id = UUID()
        newItem.name = name
        newItem.isCompleted = false
        newItem.list = list

        do {
            try context.save()
            return newItem
        } catch {
            print("Failed to add item: \(error.localizedDescription)")
            return nil
        }
    }

    /// Fetch all items for a specific list
    func fetchItems(for list: ListEntity) -> [ItemEntity] {
        guard let items = list.items as? Set<ItemEntity> else { return [] }
        return Array(items)
    }

    /// Delete an item
    func deleteItem(item: ItemEntity) {
        let context = container.viewContext
        context.delete(item)
        saveContext()
    }

    /// Toggle completion of an item
    func toggleCompletion(for item: ItemEntity) {
        let context = container.viewContext
        item.isCompleted.toggle()
        saveContext()
    }

    // MARK: - Core Data Context Saving

    /// Save the current context
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
}

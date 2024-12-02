//
//  FZCDTodoListApp.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import SwiftUI

@main
struct FZCDTodoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            FZCDListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

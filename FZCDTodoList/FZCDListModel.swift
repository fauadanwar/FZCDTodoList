//
//  FZCDListModel.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import Foundation

class FZCDListModel: ObservableObject, Identifiable {
    @Published var id: UUID
    @Published var name: String
    @Published var items: [FZCDItemModel]

    init(id: UUID, name: String, items: [FZCDItemModel]) {
        self.id = id
        self.name = name
        self.items = items
    }
}

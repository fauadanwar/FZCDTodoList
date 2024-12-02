//
//  FZCDItemModel.swift
//  FZCDTodoList
//
//  Created by Fouad  on 01/12/24.
//

import Foundation

struct FZCDItemModel: Identifiable {
    var id: UUID
    var name: String
    var isCompleted: Bool
}

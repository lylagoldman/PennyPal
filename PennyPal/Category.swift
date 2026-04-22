//
//  Category.swift
//  PennyPal
//
//  Created by Lyla Goldman on 4/22/26.
//

import Foundation

struct Category: Identifiable, Codable {
    var id = UUID()
    var name: String
    var iconName: String // e.g., "cart.fill" for groceries
    var colorHex: String // e.g., "#FF5733"
}

let groceryCategory = Category(name: "Groceries", iconName: "cart", colorHex: "#00FF00")



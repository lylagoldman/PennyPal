//
//  Category.swift
//  PennyPal
//
//  Created by Lyla on 4/22/26.
//

import Foundation
import SwiftUI

struct Category: Identifiable, Codable {
    var id = UUID()
    var name: String
    var iconName: String
    var colorHex: String
    var kind: CategoryKind = .expense
}

enum CategoryKind: String, Codable {
    case income
    case expense
}

extension Category {
    var swiftUIColor: Color {
        Color(hex: colorHex) ?? .mediumMint
    }
}

private extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}

//
//  ButtonView.swift
//  PennyPal
//
//  Created by Lyla Goldman on 10/30/25.
//

import SwiftUI

struct ButtonView: View {
    var title: String
    var buttonColor: Color
    var newScreen: AnyView
    
    var body: some View {
        NavigationLink(destination: newScreen) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(buttonColor)
                    .frame(width: 200, height: 45)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
            }
        }
    }
}

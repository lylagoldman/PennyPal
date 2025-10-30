//
//  ContentView.swift
//  PennyPal
//
//  Created by Lyla Goldman on 10/24/25.
//

import SwiftUI

struct ContentView: View {
    var images = ["VLogo", "HLogo"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(images[0])
                    .resizable()
                    .frame(width: 650, height: 280)
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

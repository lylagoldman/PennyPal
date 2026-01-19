//
//  LogoViews.swift
//  PennyPal
//
//  Created by Lyla Goldman on 10/30/25.
//

import SwiftUI

struct VLogoView: View {
    var body: some View {
        VStack {
            Image("VLogo")
                .resizable()
                .frame(width: 650, height: 259)
        }
    }
}


struct HLogoView: View {
    var body: some View {
        VStack {
            Image("HLogo")
                .resizable()
                .frame(width: 320, height: 140)
        }
    }
}

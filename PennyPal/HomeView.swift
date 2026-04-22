//
//  HomeView.swift
//  PennyPal
//
//  Created by Lyla Goldman on 4/22/26.
//

import SwiftUI

struct HomeView: View {
    let user: UserProfile
    var body: some View {
        VStack {
            HStack {
                Text("Welcome,\n\(user.firstName)!")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .frame(maxWidth:.infinity, alignment: .leading)
                
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .padding(15)
                    .overlay(Circle().stroke(Color.charcoal.opacity(0.2), lineWidth: 2))
                        .padding(.trailing, 15)
                
            }
            
            Text("Your Balance")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.vertical, 3)
            
            Text("\(user.preferredCurrency)100,000") //example of balance
                .font(.largeTitle)
                .fontWeight(.heavy)
            
        }
    }
}


struct Transaction: Identifiable, Codable{
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var categoryId: UUID // Links to a Category's ID
    var note: String?
}

struct Budget: Identifiable, Codable {
    var id = UUID()
    var limit: Double
    var categoryId: UUID
    var period: String // e.g., "Monthly" or "Weekly"
}

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var preferredCurrency: String
    var joinedDate: Date
}


#Preview {
    HomeView(user: UserProfile(firstName: "Lyla", lastName: "Goldman", email: "lyla@example.com", preferredCurrency: "$", joinedDate: .init()))
}

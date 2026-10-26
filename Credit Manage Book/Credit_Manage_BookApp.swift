//
//  Credit_Manage_BookApp.swift
//  Credit Manage Book
//
//  Created by Sequoia on 23/10/26.
//

import SwiftUI
import SwiftData

@main
struct Credit_Manage_BookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Customer.self, Credit.self, CreditItem.self, Product.self, Payment.self])
    }
}

//
//  MainTabView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            DetailsView()
                .tabItem { Label("Details", systemImage: "list.clipboard") }
            AddProductView()
                .tabItem { Label("Add Products", systemImage: "plus.circle.fill") }
        }
        .tint(.indigo)
    }
}

//
//  SplashView.swift
//  Credit Manage Book
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            MainTabView()
        } else {
            ZStack {
                Color.indigo
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Credit Manage Book")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Manage your credits with ease")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                    
                    // Navigate to MainTabView after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

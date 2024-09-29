//
//  ContentView.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var accessToken: String? = nil
    private let authManager = AuthManager()

    var body: some View {
        if isAuthenticated {
            TabView {
                SparksPage()
                    .tabItem {
                        Image(.sparks250X250)
                            .resizable().frame(width: 100, height: 100)
                        //Text("SPARKS").foregroundStyle(Color.white)
                    }
                ConnectionsPage()
                    .tabItem {
                        Image(.people250X250)
                        //Text("Connections")
                    }
            }
        } else {
            ZStack {
                // Background gradient
                let customPink = UIColor(red: 0xF0, green: 0xB4, blue: 0xFF).color
                let customPurple = UIColor(red: 0x6D, green: 0x78, blue: 0xED).color
                LinearGradient(
                    gradient: Gradient(colors: [customPink, customPurple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Custom image for logo
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120) // Adjust the size as needed
                        .padding(.top, 40) // Add top padding for spacing

                    // Welcome text and login button
                    Text("Welcome to SocialSpark!")
                        .font(.largeTitle)
                        .foregroundColor(.white) // Set text color to white to match the gradient

                    Button("Login") {
                        login()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20) // Add some padding above the button for spacing
                }
                .padding() // General padding for the VStack
            }
        }
    }

    private func login() {
        authManager.login { success, token in
            if success, let token = token {
                self.isAuthenticated = true
                self.accessToken = token
                
            }
        }
    }
}



#Preview {
    ContentView()
}

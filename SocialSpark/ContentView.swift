//
//  ContentView.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = true
    @State private var accessToken: String? = nil
    private let authManager = AuthManager()

    var body: some View {
        if isAuthenticated {
            TabView {
                SparksPage()
                    .tabItem {
                        Image(.sparksSelectPage)
                            .resizable().frame(width: 100, height: 100)
                        Text("Sparks")
                    }
                ConnectionsPage()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Connections")
                    }
            }
        } else {
            VStack {
                Text("Welcome to SocialSpark!")
                Button("Login") {
                    login()
                }
                .buttonStyle(.borderedProminent)
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

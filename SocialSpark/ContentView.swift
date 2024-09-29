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
                        Image(systemName: "house")
                        Text("Sparks")
                    }
                ConnectionsPage()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Connections")
                    }
                StatsPage()
                    .tabItem {
                        Image(systemName: "circle")
                        Text("Stats")
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
    
    func fetchUserInfo(accessToken: String) {
        // Auth0 userinfo endpoint
        let url = URL(string: "https://<YOUR_DOMAIN>.auth0.com/userinfo")!
        
        // Create a URL request with the access token in the Authorization header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Create a data task to fetch user info
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle error
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Handle response and data
            if let data = data {
                do {
                    // Try to decode JSON response into a dictionary
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("User Info: \(json)")
                    }
                } catch {
                    print("Failed to parse user info: \(error.localizedDescription)")
                }
            }
        }
        
        // Start the request
        task.resume()
    }

}

#Preview {
    ContentView()
}

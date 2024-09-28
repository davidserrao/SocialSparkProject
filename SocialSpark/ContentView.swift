//
//  ContentView.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI
import Auth0
import Foundation

struct ContentView: View {
    
    @State var isAuthenticated = false
    @State let apiURL = ""
    
    var body: some View {
        if isAuthenticated {
            TabView{
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
                        Text("Sparks")
                    }
            }
        } else {
            VStack() {
                Text("Welcome to SocialSpark!")
                Button("Login") {
                    login()
                }
                .buttonStyle(.borderedProminent)
                Button("public") {
                    pub()
                }
                Button("private") {
                    priv()
                }
            }
        }
        
    }
}

extension ContentView {
    private func login() {
        Auth0
            .webAuth()
            .start { result in
                
                switch result {
                    
                case .failure(let error):
                    print("Failure: \(error)")
                    
                case .success(let credentials):
                    self.isAuthenticated = true
                    print("Credentials: \(credentials)")
                    print("ID Token: \(credentials.idToken)")
                }
                
            }
    }
    
    private func logout() {
        Auth0
            .webAuth()
            .clearSession { result in
                
                switch result {
                    
                case .failure(let error):
                    print("Failure: \(error)")
                    
                case .success(let credentials):
                    self.isAuthenticated = false
                    
                }
                
            }
    }
    
    private func pub() {
        
    }
    
    private func priv() {
        
    }
}

#Preview {
    ContentView()
}

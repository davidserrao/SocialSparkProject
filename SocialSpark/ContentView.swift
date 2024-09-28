//
//  ContentView.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}

#Preview {
    ContentView()
}

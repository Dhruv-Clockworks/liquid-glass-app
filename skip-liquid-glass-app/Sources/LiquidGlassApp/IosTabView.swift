//
//  IosTabView.swift
//  skip-liquid-glass-app
//
//  Created by Dhruv Chhatbar on 21/07/26.
//
import SwiftUI

struct IosTabView: View {
    @State var selectedTab = "Home"

    var body: some View {
        GeometryReader { proxy in
            TabView(selection: $selectedTab) {
                TabPlaygroundContentView(label: "Home", proxy: proxy, selectedTab: $selectedTab)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag("Home")
                TabPlaygroundContentView(label: "Favorites", proxy: proxy, selectedTab: $selectedTab)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .tag("Favorites")
                TabPlaygroundContentView(label: "Info", proxy: proxy, selectedTab: $selectedTab)
                    .tabItem { Label("Info", systemImage: "info.circle.fill") }
                    .tag("Info")
            }
            .padding(proxy.safeAreaInsets.bottom)
        }
        
    }
}

struct TabPlaygroundContentView: View {
    let label: String
    let proxy: GeometryProxy
    @Binding var selectedTab: String

    var body: some View {
        VStack {
            Text("proxy.size.width: \(proxy.size.width)")
            Text("proxy.size.height: \(proxy.size.height)")
            Text("proxy.safeAreaInsets: \(proxy.safeAreaInsets)")
            
            
            Text(label).bold()
            if label != "Home" {
                Button("Switch to Home") {
                    selectedTab = "Home"
                }
                .padding()
                .background(Color.cyan)
            }
            if label != "Favorites" {
                Button("Switch to Favorites") {
                    selectedTab = "Favorites"
                }
                .padding()
                .background(Color.red)
            }
            if label != "Info" {
                Button("Switch to Info") {
                    selectedTab = "Info"
                }
                .padding()
                .background(Color.gray)
            }
        }
    }
}

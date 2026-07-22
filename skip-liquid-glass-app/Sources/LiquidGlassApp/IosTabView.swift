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
//        GeometryReader { proxy in
                TabView(selection: $selectedTab) {
                    TabPlaygroundContentView(label: "Home", selectedTab: $selectedTab)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                            .font(.system(size: 10))}
                        .tag("Home")
                    TabPlaygroundContentView(label: "Favorites", selectedTab: $selectedTab)
                        .tabItem { Label("Favorites", systemImage: "heart.fill") }
                        .tag("Favorites")
                    TabPlaygroundContentView(label: "Info", selectedTab: $selectedTab)
                        .tabItem { Label("Info", systemImage: "info.circle.fill") }
                        .tag("Info")
                
            }
                .toolbarBackgroundVisibility(.hidden, for: .tabBar)
            .padding(.bottom, 16)
//        }
    }
}

struct TabPlaygroundContentView: View {
    let label: String
    let proxy: GeometryProxy? = nil
    @Binding var selectedTab: String

    var body: some View {
        ZStack {
            Color.cyan
            VStack {
                Text("proxy.size.width: \(proxy?.size.width ?? 0)")
                Text("proxy.size.height: \(proxy?.size.height ?? 0) ")
                
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
        .background(.cyan)
        .ignoresSafeArea()
    }
}

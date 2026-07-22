//
//  TabView.swift
//  demo-lib
//
//  Created by Dhruv Chhatbar on 17/07/26.
//

import Foundation
import SwiftUI

public struct SkipGlassTabView: View {
    public init() {}
    public var body: some View {
        VStack {
#if os(iOS)
            IosTabView()
#else
            ComposeView {
                        LiquidGlassTabScreenComposer(currentDevice: tier.rawValue)
            }
#endif
        }
    }
}

struct IosTabView: View {
    @State var selectedTab = "Home"

    var body: some View {
        TabView(selection: $selectedTab) {

            TabPlaygroundContentView(label: "Home", selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag("Home")
            TabPlaygroundContentView(label: "Favorites", selectedTab: $selectedTab)
                .tabItem { Label("Favorites", systemImage: "heart.fill") }
                .tag("Favorites")
            TabPlaygroundContentView(label: "Info", selectedTab: $selectedTab)
                .tabItem { Label("Info", systemImage: "info.circle.fill") }
                .tag("Info")
        }
    }
}

struct TabPlaygroundContentView: View {
    let label: String
    @Binding var selectedTab: String

    var body: some View {
        VStack {
            Text(label).bold()
            if label != "Home" {
                Button("Switch to Home") {
                    selectedTab = "Home"
                }
            }
            if label != "Favorites" {
                Button("Switch to Favorites") {
                    selectedTab = "Favorites"
                }
            }
            if label != "Info" {
                Button("Switch to Info") {
                    selectedTab = "Info"
                }
            }
        }
    }
}

#if SKIP
struct LiquidGlassTabScreenComposer: ContentComposer {
    let currentDevice: String
    @Composable func Compose(context: ComposeContext) {
        LiquidGlassTabScreen(modifier: context.modifier, currentDevice: currentDevice)
    }
}
#endif

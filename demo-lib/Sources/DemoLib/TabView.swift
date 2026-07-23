import Foundation
import SwiftUI
#if SKIP
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
#endif

// Unified liquid glass tab view.
// iOS: native TabView with liquid glass styling.
// Android: Kyant-backed LiquidGlassTabView composable via Skip bridge.
public struct LiquidGlassTabView: View {
    @State var selectedTab = "Home"

    public init() {}

    public var body: some View {
#if os(iOS)
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
#else
        ComposeView {
            LiquidGlassAndroidTabComposer()
        }
#endif
    }
}

struct TabPlaygroundContentView: View {
    let label: String
    @Binding var selectedTab: String

    var body: some View {
        VStack {
            Text(label).bold()
            if label != "Home" {
                Button("Switch to Home") { selectedTab = "Home" }
            }
            if label != "Favorites" {
                Button("Switch to Favorites") { selectedTab = "Favorites" }
            }
            if label != "Info" {
                Button("Switch to Info") { selectedTab = "Info" }
            }
        }
    }
}
#if SKIP
// Bridges to the Kotlin LiquidGlassTabView composable in LiquidBottomBar.kt.
struct LiquidGlassAndroidTabComposer: ContentComposer {
    @Composable func Compose(context: ComposeContext) {
        demo.lib.LiquidGlassTabView(modifier: context.modifier) {
            tabItem(icon: Icons.Filled.Home, label: "Home") {
                TabPlaygroundContentView(label: "Home", selectedTab: .constant("Home"))
            }
            tabItem(icon: Icons.Filled.Favorite, label: "Favorites") {
                TabPlaygroundContentView(label: "Favorites", selectedTab: .constant("Favorites"))
            }
            tabItem(icon: Icons.Filled.Info, label: "Info") {
                TabPlaygroundContentView(label: "Info", selectedTab: .constant("Info"))
            }
        }
    }
}
#endif

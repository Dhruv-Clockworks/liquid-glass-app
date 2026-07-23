import SwiftUI

enum ContentTab: String, Hashable {
    case welcome, home, settings
}

public struct WelcomeView1 : View {
    @Binding var welcomeName: String
    public init (value: Binding<String>) {
        self._welcomeName = value
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text("Hello [\(welcomeName)](https://skip.dev)!")
                .padding()
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
        }
        .font(.largeTitle)
    }
}

public struct SettingsView1 : View {
    @Binding var name: String
    public init (value: Binding<String>) {
        self._name = value
    }
    public var body: some View {
        VStack(spacing: 10) {
            Text("Hello [\(name)](https://skip.dev)!")
                .padding()
            Form {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Version \(version) (\(buildNumber))")
                }
                HStack {
                    PlatformHeartView()
                    Text("Powered by [Skip](https://skip.dev)")
                }
            }
        }
    }
}

/// A view that shows a blue heart on iOS and a green heart on Android.
struct PlatformHeartView : View {
    var body: some View {
       #if SKIP
       ComposeView { ctx in // Mix in Compose code!
           androidx.compose.material3.Text("💚", modifier: ctx.modifier)
       }
       #else
       Text(verbatim: "💙")
       #endif
    }
}


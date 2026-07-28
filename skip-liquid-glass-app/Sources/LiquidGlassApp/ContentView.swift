import SwiftUI
// import SkipFuse

public enum ContentTab: String, Hashable {
    case welcome, home, settings
}

#if os(Android)
typealias MyTabView = DemoTabView
#else
typealias MyTabView = TabView
#endif

public struct LiteContentView: View {
    public init () {}
    @State var tab = ContentTab.settings
    @AppStorage("name") var welcomeName = "Skipper"
    @AppStorage("appearance") var appearance = ""
    @State var viewModel = ViewModel()

    public var body: some View {
                
        MyTabView(selection: $tab) {
            Tab("Welcome", systemImage: "heart.fill", value: ContentTab.welcome) {
                NavigationStack {
                    WelcomeView(welcomeName: $welcomeName)
                }
            }
            Tab("Settings", systemImage: "gearshape.fill", value: ContentTab.settings) {
                SettingsView(welcomeName: $welcomeName, tab: $tab)
                        .navigationTitle("Settings")
            }
        }
    }
}

public struct WelcomeView : View {
    public init(heartBeating: Bool = false, welcomeName: Binding<String>) {
        self.heartBeating = heartBeating
        self._welcomeName = welcomeName
    }
    @State var heartBeating = false
    @Binding var welcomeName: String

   public var body: some View {
       ZStack {
           Color.green
           VStack(spacing: 10) {
               Text("Hello [\(welcomeName)](https://skip.dev)!")
               TextField("Enter Value", text: $welcomeName)
                   .padding()
               Image(systemName: "heart.fill")
                   .foregroundStyle(.red)
                   .scaleEffect(heartBeating ? 1.5 : 1.0)
                   .task {
                       withAnimation(.easeInOut(duration: 1).repeatForever()) {
                           heartBeating = true
                       }
                   }
           }
           .font(.largeTitle)
       }
//       .navigationSubtitle("sub title asdasdasd")
       .ignoresSafeArea()
    }
}

public struct SettingsView : View {
    public init(welcomeName: Binding<String>, tab: Binding<ContentTab>) {
        self._welcomeName = welcomeName
        self._tab = tab
    }
    @Binding var tab: ContentTab
    @Binding var welcomeName: String
    @State var gotoSettings = false

    public var body: some View {
        Form {
            TextField("Name", text: $welcomeName)
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("Version \(version) (\(buildNumber))")
            }
            HStack {
                PlatformHeartView()
                Text("Powered by [Skip](https://skip.dev)")
            }
                ZStack {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 150, height: 150, alignment: .center)
                    
                    VStack(spacing: 20) {
                        HStack {
                            Button("Glass") {
                                tab = .welcome
                            }
                            .buttonStyle(.glass)
                            
                            Button("Go to Settings") {
                                gotoSettings = true
                            }
                            .buttonStyle(.glassProminent)
                        }
                        HStack {
                            
                            Button {
                                tab = .welcome
                            } label: {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)

                            }
                            .buttonStyle(.glass)
                            
                            Button {
                                
                            } label: {
                                VStack(spacing: 0) {
                                    Image(systemName: "gearshape.fill")
                                    Text("gearshape.fill")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                    .navigationDestination(isPresented: $gotoSettings) {
                        SettingsView(welcomeName: $welcomeName, tab: $tab)
                            .navigationTitle(welcomeName)
                    }
            }
        }
        .navigationTitle("Dhruvs asdasd")
    }
}

/// A view that shows a blue heart on iOS and a green heart on Android.
struct PlatformHeartView : View {
    var body: some View {
        #if os(Android)
        ComposeView {
            HeartComposer()
        }
        #else
        Text(verbatim: "💙")
        #endif
    }
}

#if SKIP
/// Use a ContentComposer to integrate Compose content. This code will be transpiled to Kotlin.
struct HeartComposer : ContentComposer {
    @Composable func Compose(context: ComposeContext) {
        androidx.compose.material3.Text("💚", modifier: context.modifier)
    }
}
#endif


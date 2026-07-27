import SwiftUI
// import SkipFuse
import DemoLib

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
        
//        MyTabView(selection: $tab) {
//            Tab("423424242342", systemImage: "house.fill", value: ContentTab.home) {
//                fourr(welcomeName: $welcomeName)
//            }
//            Tab("323123", systemImage: "house.fill", value: ContentTab.welcome) {
//                threee(welcomeName: $welcomeName)
//            }
//            Tab("2", systemImage: "house.fill", value: ContentTab.settings) {
//                twoo(welcomeName: $welcomeName)
//            }
//        }
        
        MyTabView(selection: $tab) {
            Tab("Welcome", systemImage: "heart.fill", value: ContentTab.welcome) {
                NavigationStack {
                    WelcomeView(welcomeName: $welcomeName)
                }
            }
            Tab("Settings", systemImage: "gearshape.fill", value: ContentTab.settings) {
                NavigationStack {
                    SettingsView(welcomeName: $welcomeName, tab: $tab)
                        .navigationTitle("Settings")
                }
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
       .ignoresSafeArea()
    }
}

struct ItemListView : View {
    @Environment(ViewModel.self) var viewModel: ViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(value: item) {
                    Label {
                        Text(item.itemTitle)
                    } icon: {
                        if item.favorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            .onDelete { offsets in
                viewModel.items.remove(atOffsets: offsets)
            }
            .onMove { fromOffsets, toOffset in
                viewModel.items.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
        .navigationDestination(for: Item.self) { item in
            ItemView(item: item)
                .navigationTitle(item.itemTitle)
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    withAnimation {
                        viewModel.items.insert(Item(), at: 0)
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
}

struct ItemView : View {
    @State var item: Item
    @Environment(ViewModel.self) var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            TextField("Title", text: $item.title)
                .textFieldStyle(.roundedBorder)
            Toggle("Favorite", isOn: $item.favorite)
            DatePicker("Date", selection: $item.date)
            Text("Notes").font(.title3)
            TextEditor(text: $item.notes)
                .border(Color.secondary, width: 1.0)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save(item: item)
                    dismiss()
                }
                .disabled(!viewModel.isUpdated(item))
            }
        }
    }
}

public struct SettingsView : View {
    public init(welcomeName: Binding<String>, tab: Binding<ContentTab>) {
        self._welcomeName = welcomeName
        self._tab = tab
    }
    @Binding var tab: ContentTab
    @Binding var welcomeName: String

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
            Button("change to welcome") {
                tab = .welcome
            }
            #if !SKIP
            Button("Glass") {
            }.buttonStyle(.glass)
            Button("GlassProminent") {
            }.buttonStyle(.glassProminent)
            #endif
        }
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

#if SKIP
//struct DemoView: ContentComposer {
//    var str: Binding<String>
//    
//    @Composable func Compose(context: ComposeContext) {
//        LiquidGlassTabView {
//            tabItem(
//                icon: LiquidIcons.welcome,
//                label: "Welcome"
//            ) {
//                NavigationStack {
//                    WelcomeView(welcomeName: str)
//                }.Compose()
//            }
//            tabItem(
//                icon: LiquidIcons.settings,
//                label: "Settings"
//            ) {
//                NavigationStack {
//                    SettingsView(welcomeName: str)
//                        .navigationTitle("Settings")
//                }.Compose()
//            }
//        }
//    }
//}
/*
struct DemoViewLite: ContentComposer {
    @Composable func Compose(context: ComposeContext) {
        demo.lib.LiquidGlassTabView {
            tabItem(
                icon: LiquidIcons.welcome,
                label: "Welcome"
            ) {
                NavigationStack {
                    Text("ASd")
                }.Compose()
            }
            tabItem(
                icon: LiquidIcons.settings,
                label: "Settings"
            ) {
                NavigationStack {
                    Text("sdasdasd")
                }.Compose()
            }
        }
    }
}
 */
#endif

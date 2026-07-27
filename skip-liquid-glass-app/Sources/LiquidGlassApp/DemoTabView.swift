//
//  DemoTabView.swift
//  skip-liquid-glass-app
//
//  Created by Dhruv Chhatbar on 24/07/26.
//
import Foundation
import SkipUI

#if SKIP
import androidx.compose.animation.Animatable
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarDefaults
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemColors
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.NavigationRail
import androidx.compose.material3.NavigationRailItem
import androidx.compose.material3.NavigationRailItemDefaults
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.contentColorFor
import androidx.compose.material3.adaptive.currentWindowAdaptiveInfo
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffoldDefaults
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffoldLayout
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteType
import androidx.compose.material3.adaptive.navigationsuite.rememberNavigationSuiteScaffoldState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation3.runtime.NavBackStack
import androidx.navigation3.runtime.NavEntry
import androidx.navigation3.runtime.NavKey
import androidx.navigation3.runtime.rememberDecoratedNavEntries
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import androidx.navigation3.ui.defaultPopTransitionSpec
import androidx.navigation3.ui.defaultPredictivePopTransitionSpec
import androidx.navigation3.ui.defaultTransitionSpec
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import kotlin.math.abs

#endif

// SKIP @bridge
public struct DemoTabView : View, SkipUI.Renderable {
    let selection: Binding<Any>?
    let content: SkipUI.ComposeBuilder
    
    public init(@ViewBuilder content: () -> any View) {
        self.selection = nil
        self.content = SkipUI.ComposeBuilder.from(content)
    }
    
    public init(selection: Any?, @ViewBuilder content: () -> any View) {
        self.selection = selection as! Binding<Any>?
        self.content = SkipUI.ComposeBuilder.from(content)
    }
    
    
    public init(selectionGet: (() -> Any)?, selectionSet: ((Any) -> Void)?, bridgedContent: any View) {
        if let selectionGet, let selectionSet {
            self.selection = Binding(get: selectionGet, set: selectionSet)
        } else {
            self.selection = nil
        }
        self.content = ComposeBuilder.from { bridgedContent }
    }
    
#if SKIP
    @Composable private func EvaluateContent(context: skip.ui.ComposeContext) -> kotlin.collections.List<skip.ui.Renderable> {
        // Evaluate our content without recursively evaluating every custom tab view. We only want to fully
        // evaluate views when we render them
        let options = EvaluateOptions(isKeepNonModified: true).value
        let renderables = content.Evaluate(context: context, options: options)
        var tabContent: kotlin.collections.MutableList<Renderable> = mutableListOf()
        for renderable in renderables {
            tabContent.add(renderable)
        }
        return tabContent
    }
    
    @Composable override func Render(context: skip.ui.ComposeContext) {
        let tabContext = context.content()
        let tabRenderables = EvaluateContent(context: tabContext)
        
        let tabs: kotlin.collections.List<Tab?> = tabRenderables.map {
            let renderable = $0 as skip.ui.Renderable
            if let tab = renderable.strip() as? Tab {
                return tab
            } else {
                return nil
            }
        }
        createTabBar(tabs, context: tabContext)
    }
    
    @Composable func createTabBar(_ tabs: kotlin.collections.List<Tab?>, context: skip.ui.ComposeContext) {
        var initialIndex = 0
        if let sel = selection {
            let selValue = sel.get()
            for i in 0..<tabs.size {
                if let tab = tabs[i], let tabValue = tab.value {
                    if tabValue == selValue {
                        initialIndex = i
                        break
                    }
                }
            }
        }

        skip.ui.LiquidGlassTabView(
            selectedIndex: initialIndex,
            onTabSelected: { index in
                if let tab = tabs[index], let tabValue = tab.value {
                    selection?.set(tabValue)
                }
            }
        ) {
            for tabIndex in 0..<tabs.size {
                if let tab = tabs[tabIndex] {
                    tabItem(
                        icon: { tab.RenderImage(context: context.content()) },
                        title: { tab.RenderTitle(context: context.content()) }
                    ) {
                        tab.Render(context: context.content())
                    }
                }
            }
        }
    }
    
    #endif
    public var body: some View {
        
#if os(Android)
        Text("Android")
#else
        Text("iOS")
#endif
    }
}

#if SKIP
struct EvaluateOptions {
    private static let keepForEach = 1 << 0
    private static let keepNonModified = 1 << 1
    // We use values < 1000 for bitwise options and add 1000 per lazy item level (+ 1)
    private static let lazyItemLevels = 1000

    init(_ value: Int) {
        self.value = value
    }

    init(isKeepForEach: Bool = false, isKeepNonModified: Bool = false, lazyItemLevel: Int? = nil) {
        var options = EvaluateOptions(0)
        options.isKeepForEach = isKeepForEach
        options.isKeepNonModified = isKeepNonModified
        options.lazyItemLevel = lazyItemLevel
        self = options
    }

    private(set) var value: Int

    /// Option to keep `ForEach` instances rather than evaluating them.
    var isKeepForEach: Bool {
        get {
            return (value % Self.lazyItemLevels) & Self.keepForEach == Self.keepForEach
        }
        set {
            if newValue {
                value = value | Self.keepForEach
            } else {
                value = value & ~Self.keepForEach
            }
        }
    }

    /// Option to keep any view that is not a `ModifiedContent` rather than evaluating it.
    ///
    /// If the view is not a `Renderable`, it is wrapped in one.
    ///
    /// - Warning: Only works reliably when evaluating a `ComposeBuilder`.
    var isKeepNonModified: Bool {
        get {
            return (value % Self.lazyItemLevels) & Self.keepNonModified == Self.keepNonModified
        }
        set {
            if newValue {
                value = value | Self.keepNonModified
            } else {
                value = value & ~Self.keepNonModified
            }
        }
    }

    /// Manage lazy item evaluation.
    ///
    /// - Seealso: `LazyItemFactory`
    var lazyItemLevel: Int? {
        get {
            guard value >= Self.lazyItemLevels else {
                return nil
            }
            var level = 0
            while true {
                value -= Self.lazyItemLevels
                guard value >= Self.lazyItemLevels else {
                    break
                }
                level += 1
            }
            return level
        }
        set {
            var value = self.value % Self.lazyItemLevels
            if let newValue {
                value += Self.lazyItemLevels * (newValue + 1)
            }
            self.value = value
        }
    }
}
#endif

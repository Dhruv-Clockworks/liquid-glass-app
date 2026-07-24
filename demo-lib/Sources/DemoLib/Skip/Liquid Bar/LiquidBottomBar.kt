package demo.lib

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp

import com.kyant.backdrop.Backdrop
import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberCombinedBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop
import com.kyant.backdrop.drawBackdrop
import com.kyant.backdrop.effects.blur
import com.kyant.backdrop.effects.lens
import com.kyant.backdrop.effects.vibrancy
import com.kyant.backdrop.highlight.Highlight
import com.kyant.backdrop.shadow.InnerShadow
import com.kyant.backdrop.shadow.Shadow

import kotlin.math.abs
import kotlin.math.roundToInt

import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch

// Icon constants for use from Swift #if SKIP blocks.
object LiquidIcons {
    val welcome = Icons.Filled.Favorite
    val home = Icons.Filled.Home
    val settings = Icons.Filled.Settings
}

// A single tab entry: composable icon, title, and body content.
class GlassTab(
    val icon: @Composable () -> Unit,
    val title: @Composable () -> Unit,
    val content: @Composable () -> Unit
)

// DSL scope for LiquidGlassTabView — mirrors SwiftUI's @ViewBuilder tabs.
class LiquidGlassTabScope {
    internal val tabs = mutableListOf<GlassTab>()

    fun tabItem(
        icon: @Composable () -> Unit,
        title: @Composable () -> Unit,
        content: @Composable () -> Unit
    ) {
        tabs.add(GlassTab(icon = icon, title = title, content = content))
    }
}

@Composable
fun LiquidGlassTabView(
    modifier: Modifier = Modifier,
    content: LiquidGlassTabScope.() -> Unit
) {
    val scope = remember { LiquidGlassTabScope().apply(content) }
    val tabs = scope.tabs
    if (tabs.isEmpty()) return

    val backdrop = rememberLayerBackdrop { drawContent() }
    var selectedIndex by rememberSaveable { mutableIntStateOf(0) }

    Box(modifier = modifier.fillMaxSize()) {
        AnimatedContent(
            targetState = selectedIndex,
            modifier = Modifier.fillMaxSize().layerBackdrop(backdrop),
            transitionSpec = {
                fadeIn(animationSpec = tween(400)) togetherWith fadeOut(animationSpec = tween(400))
            },
            label = "TabContentTransition"
        ) { targetIndex ->
            if (targetIndex in tabs.indices) tabs[targetIndex].content()
        }

        // Measure available width, then size the bar to content (ideal 88dp per tab),
        // falling back to equal sharing when the screen is too narrow.
        BoxWithConstraints(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            contentAlignment = Alignment.Center
        ) {
            val density = LocalDensity.current
            val idealPx = with(density) { (88.dp * tabs.size).toPx() }
            val maxPx = (constraints.maxWidth.toFloat() - with(density) { 48.dp.toPx() })
                .coerceAtLeast(0f)
            val barWidth = with(density) { idealPx.coerceAtMost(maxPx).toDp() }
            LiquidGlassTabBar(
                backdrop = backdrop,
                tabs = tabs,
                selectedIndex = selectedIndex,
                onTabSelected = { selectedIndex = it },
                modifier = Modifier.width(barWidth)
            )
        }
    }
}

@Composable
fun LiquidGlassTabBar(
    backdrop: Backdrop,
    tabs: List<GlassTab>,
    selectedIndex: Int,
    onTabSelected: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    if (tabs.isEmpty()) return

    val isLightTheme = !isSystemInDarkTheme()
    val accentColor =
        if (isLightTheme) Color(0xFF0088FF)
        else Color(0xFF0091FF)
    val containerColor =
        if (isLightTheme) Color(0xFFFAFAFA).copy(alpha = 0.4f)
        else Color(0xFF121212).copy(alpha = 0.4f)
    val baseContentColor = if (isLightTheme) Color.Black else Color.White

    val tabsBackdrop = rememberLayerBackdrop()
    val animationScope = rememberCoroutineScope()

    BoxWithConstraints(
        modifier = modifier,
        contentAlignment = Alignment.CenterStart
    ) {
        val density = LocalDensity.current
        val tabWidth = with(density) {
            (constraints.maxWidth.toFloat() - 8f.dp.toPx()) / tabs.size
        }

        // Rubber-band nudge: the whole bar leans slightly in the drag direction,
        // decaying via EaseOut, then springs back to 0 once the drag ends.
        val offsetAnimation = remember { Animatable(0f) }
        val panelOffset by remember(density) {
            derivedStateOf {
                val fraction = (offsetAnimation.value / constraints.maxWidth).coerceIn(-1f, 1f)
                with(density) {
                    4f.dp.toPx() * (if (fraction >= 0f) 1f else -1f) * EaseOut.transform(abs(fraction))
                }
            }
        }

        val isLtr = LocalLayoutDirection.current == LayoutDirection.Ltr

        // Local mirror of selectedIndex: driven by taps, drag-stop, and external
        // selectedIndex changes alike, so the pill animation has one source of truth.
        var currentIndex by remember { mutableIntStateOf(selectedIndex) }

        // DampedDragAnimation: drives the pill position as a float tab index.
        // pressProgress / scaleX / scaleY animate on press for the squish effect.
        val anim = remember {
            DampedDragAnimation(
                animationScope = animationScope,
                initialValue = selectedIndex.toFloat(),
                valueRange = 0f..(tabs.size - 1).toFloat(),
                visibilityThreshold = 0.001f,
                initialScale = 1f,
                pressedScale = 1.4f,
                onDragStarted = { _ -> },
                onDragStopped = {
                    val targetIndex = targetValue.roundToInt().coerceIn(0, tabs.size - 1)
                    currentIndex = targetIndex
                    animateToValue(targetIndex.toFloat())
                    animationScope.launch {
                        offsetAnimation.animateTo(0f, spring(1f, 300f, 0.5f))
                    }
                },
                onDrag = { _, dragAmount ->
                    val direction = if (isLtr) 1f else -1f
                    updateValue(
                        (targetValue + dragAmount.x / tabWidth * direction)
                            .coerceIn(0f, (tabs.size - 1).toFloat())
                    )
                    animationScope.launch {
                        offsetAnimation.snapTo(offsetAnimation.value + dragAmount.x)
                    }
                }
            )
        }

        // Sync externally-driven selection changes (e.g. back-stack navigation).
        LaunchedEffect(selectedIndex) {
            if (selectedIndex != currentIndex) currentIndex = selectedIndex
        }
        // Any currentIndex change (tap or drag-stop) animates the pill and notifies the caller.
        LaunchedEffect(anim) {
            snapshotFlow { currentIndex }
                .drop(1)
                .collectLatest { index ->
                    anim.animateToValue(index.toFloat())
                    onTabSelected(index)
                }
        }

        // Shared glow, anchored to the pill's own position rather than the finger,
        // fading in on press and out on release.
        val interactiveHighlight = remember {
            InteractiveHighlight(
                animationScope = animationScope,
                position = { size, _ ->
                    Offset(
                        if (isLtr) (anim.value + 0.5f) * tabWidth + panelOffset
                        else size.width - (anim.value + 0.5f) * tabWidth + panelOffset,
                        size.height / 2f
                    )
                }
            )
        }

        // ── Visible glass bar + tab icons ───────────────────────────────────
        Row(
            modifier = Modifier
                .graphicsLayer { translationX = panelOffset }
                .drawBackdrop(
                    backdrop = backdrop,
                    shape = { RoundedCornerShape(percent = 50) },
                    effects = {
                        vibrancy()
                        blur(8f.dp.toPx())
                        lens(24f.dp.toPx(), 24f.dp.toPx())
                    },
                    layerBlock = {
                        val progress = anim.pressProgress
                        val scale = 1f + (16f.dp.toPx() / size.width) * progress
                        scaleX = scale
                        scaleY = scale
                    },
                    onDrawSurface = { drawRect(containerColor) }
                )
                .then(interactiveHighlight.modifier)
                .fillMaxWidth()
                .height(70.dp)
                .padding(5.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            tabs.forEachIndexed { index, tab ->
                // Proximity: 1.0 at the selected tab, fading to 0 one tab away.
                val proximity = (1f - abs(anim.value - index.toFloat())).coerceIn(0f, 1f)
                val isSelected = index == anim.value.roundToInt()

                val iconScale by animateFloatAsState(
                    targetValue = 0.9f + proximity * 0.35f,
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioMediumBouncy,
                        stiffness = Spring.StiffnessLow
                    ),
                    label = "Scale_$index"
                )
                val iconAlpha by animateFloatAsState(
                    targetValue = if (isSelected) 1f else 0.5f,
                    animationSpec = tween(durationMillis = 200),
                    label = "Alpha_$index"
                )

                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null
                        ) {
                            currentIndex = index
                        },
                    contentAlignment = Alignment.Center
                ) {
                    CompositionLocalProvider(
                        LocalContentColor provides baseContentColor.copy(alpha = iconAlpha)
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp),
                            modifier = Modifier.scale(iconScale)
                        ) {
                            Box(modifier = Modifier.size(24.dp)) { tab.icon() }
                            tab.title()
                        }
                    }
                }
            }
        }

        // ── Hidden accent-tinted copy ────────────────────────────────────────
        // Feeds `tabsBackdrop`. The pill below reveals a lens-distorted slice of
        // this layer through a combined backdrop, which is why the icon under
        // the glass pill reads as accent-colored while the rest stay neutral.
        Row(
            modifier = Modifier
                .clearAndSetSemantics {}
                .alpha(0f)
                .layerBackdrop(tabsBackdrop)
                .graphicsLayer { translationX = panelOffset }
                .drawBackdrop(
                    backdrop = backdrop,
                    shape = { RoundedCornerShape(percent = 50) },
                    effects = {
                        val progress = anim.pressProgress
                        vibrancy()
                        blur(8f.dp.toPx())
                        lens(
                            24f.dp.toPx() * progress,
                            24f.dp.toPx() * progress
                        )
                    },
                    highlight = {
                        Highlight.Default.copy(alpha = anim.pressProgress)
                    },
                    onDrawSurface = { drawRect(containerColor) }
                )
                .then(interactiveHighlight.modifier)
                .fillMaxWidth()
                .height(60.dp)
                .padding(horizontal = 4.dp)
                .graphicsLayer(colorFilter = ColorFilter.tint(accentColor)),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            tabs.forEach { tab ->
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(2.dp)
                    ) {
                        Box(modifier = Modifier.size(24.dp)) { tab.icon() }
                        tab.title()
                    }
                }
            }
        }

        // ── Sliding liquid pill + drag surface ──────────────────────────────
        // `anim.modifier` is what actually receives touch drags; without it
        // attached here, DampedDragAnimation never sees pointer input at all.
        Box(
            modifier = Modifier
                .padding(horizontal = 4.dp)
                .graphicsLayer {
                    translationX =
                        if (isLtr) anim.value * tabWidth + panelOffset
                        else size.width - (anim.value + 1f) * tabWidth + panelOffset
                }
                .then(interactiveHighlight.gestureModifier)
                .then(anim.modifier)
                .drawBackdrop(
                    backdrop = rememberCombinedBackdrop(backdrop, tabsBackdrop),
                    shape = { RoundedCornerShape(percent = 50) },
                    effects = {
                        val progress = anim.pressProgress
                        lens(
                            10f.dp.toPx() * progress,
                            14f.dp.toPx() * progress,
                            chromaticAberration = true
                        )
                    },
                    highlight = {
                        Highlight.Default.copy(alpha = anim.pressProgress)
                    },
                    shadow = {
                        Shadow(alpha = anim.pressProgress)
                    },
                    innerShadow = {
                        InnerShadow(
                            radius = 8f.dp * anim.pressProgress,
                            alpha = anim.pressProgress
                        )
                    },
                    layerBlock = {
                        scaleX = anim.scaleX
                        scaleY = anim.scaleY

                        val velocity = anim.velocity / 10f
                        scaleX /= 1f - (velocity * 0.75f).coerceIn(-0.2f, 0.2f)
                        scaleY *= 1f - (velocity * 0.25f).coerceIn(-0.2f, 0.2f)
                    },
                    onDrawSurface = {
                        val progress = anim.pressProgress
                        drawRect(
                            if (isLightTheme) Color.Black.copy(alpha = 0.1f)
                            else Color.White.copy(alpha = 0.1f),
                            alpha = 1f - progress
                        )
                        drawRect(Color.Black.copy(alpha = 0.03f * progress))
                    }
                )
                .height(60.dp)
                .fillMaxWidth(1f / tabs.size)
        )
    }
}

package demo.lib

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop

@Composable
fun LiquidGlassTabScreen(
    modifier: Modifier = Modifier,
    currentDevice: String = ""
) {

    val backdrop = rememberLayerBackdrop {
        drawContent()
    }

    var selectedTab by rememberSaveable { mutableStateOf("Home") }

    val tabs = remember {
        listOf(
            GlassTab(Icons.Filled.Home, "Home"),
            GlassTab(Icons.Filled.Favorite, "Favorites"),
            GlassTab(Icons.Filled.Info, "Info")
        )
    }

    val selectedIndex = tabs.indexOfFirst { it.label == selectedTab }.coerceAtLeast(0)

    Box(modifier = modifier.fillMaxSize()) {

        AnimatedContent(
            targetState = selectedTab,
            modifier = Modifier
                .fillMaxSize()
                .layerBackdrop(backdrop),
            transitionSpec = {
                fadeIn(animationSpec = tween(400)) togetherWith fadeOut(animationSpec = tween(400))
            },
            label = "TabScreenTransition"
        ) { targetTab ->
            TabPlaygroundScreen(
                currentDevice = currentDevice,
                label = targetTab
            )
        }

        LiquidGlassTabBar(
            backdrop = backdrop,
            tabs = tabs,
            selectedIndex = selectedIndex,
            onTabSelected = { index -> selectedTab = tabs[index].label },
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(horizontal = 24.dp, vertical = 32.dp)
        )
    }
}

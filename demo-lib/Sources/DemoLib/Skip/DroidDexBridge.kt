package demo.lib

import android.app.Application
import android.content.Context
import com.blinkit.droiddex.DroidDex
import com.blinkit.droiddex.constants.PerformanceClass

object DroidDexBridge {

    private var isInitialized = false

    fun initialize(context: Context) {
        if (isInitialized) return
        val application = context.applicationContext as Application
        DroidDex.init(application)
        isInitialized = true
    }

    fun performanceLevel(className: String): String {
        val flag = toPerformanceClassFlag(className) ?: return "AVERAGE"
        return DroidDex.getPerformanceLevel(flag).name
    }

    fun performanceLevel(classNameA: String, classNameB: String): String {
        val a = toPerformanceClassFlag(classNameA)
        val b = toPerformanceClassFlag(classNameB)
        if (a == null || b == null) return "AVERAGE"
        return DroidDex.getPerformanceLevel(a, b).name
    }

    fun weightedPerformanceLevel(
        classNameA: String, weightA: Float,
        classNameB: String, weightB: Float
    ): String {
        val a = toPerformanceClassFlag(classNameA)
        val b = toPerformanceClassFlag(classNameB)
        if (a == null || b == null) return "AVERAGE"
        return DroidDex.getWeightedPerformanceLevel(a to weightA, b to weightB).name
    }

    private fun toPerformanceClassFlag(name: String): Int? = when (name.uppercase()) {
        "CPU" -> PerformanceClass.CPU
        "MEMORY" -> PerformanceClass.MEMORY
        "NETWORK" -> PerformanceClass.NETWORK
        "STORAGE" -> PerformanceClass.STORAGE
        "BATTERY" -> PerformanceClass.BATTERY
        else -> null
    }
}

import Foundation
import SkipFuse
import SwiftUI

public class DemoLibModule {

    public static func createDemoLibType(id: UUID, delay: Double? = nil) async throws -> DemoLibType {
        if let delay = delay {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        return DemoLibType(id: id)
    }

    /// An example of a type that can be bridged between Swift and Kotlin
    public struct DemoLibType: Identifiable, Hashable, Codable {
        public var id: UUID
    }
}

public enum DevicePerformanceTier: String {
    case excellent = "EXCELLENT"
    case high = "HIGH"
    case average = "AVERAGE"
    case low = "LOW"
}

let pLogger: Logger = Logger(subsystem: "demo-lib", category: "Performance")


//extension DemoLibModule {
//
//    public static func setupPerformanceMonitoring() {
//        #if os(Android)
//        androidSetupPerformanceMonitoring()
//        #endif
//    }
//
//    public static func performanceLevel(for className: String) -> DevicePerformanceTier {
//        #if os(Android)
//        let raw = androidPerformanceLevel(className)
//        pLogger.info("performance level value: \(raw)")
//        return DevicePerformanceTier(rawValue: raw) ?? .low
//        #else
//        return .low
//        #endif
//    }
//
//    public static func weightedPerformanceLevel(
//        classA: String, weightA: Double,
//        classB: String, weightB: Double
//    ) -> DevicePerformanceTier {
//        #if os(Android)
//        let raw = androidWeightedPerformanceLevel(classA, weightA, classB, weightB)
//        pLogger.info("weightedPerformanceLevel raw is: \(raw)")
//        return DevicePerformanceTier(rawValue: raw) ?? .low
//        #else
//        return .average
//        #endif
//    }
//}
//
//
//#if SKIP
//func androidSetupPerformanceMonitoring() {
////    pLogger.info("init called for demoLib")
//    if let context = ProcessInfo.processInfo.androidContext {
//        DroidDexBridge.initialize(context: context)
//    }
//}
//
//func androidPerformanceLevel(_ className: String) -> String {
//    return DroidDexBridge.performanceLevel(className)
//}
//
//func androidWeightedPerformanceLevel(_ classA: String, _ weightA: Double, _ classB: String, _ weightB: Double) -> String {
//    return DroidDexBridge.weightedPerformanceLevel(
//        classNameA: classA, weightA: Float(weightA),
//        classNameB: classB, weightB: Float(weightB)
//    )
//}
//#endif

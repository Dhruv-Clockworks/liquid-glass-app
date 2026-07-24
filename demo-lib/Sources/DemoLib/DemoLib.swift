import Foundation
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


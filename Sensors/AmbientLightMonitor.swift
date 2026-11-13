import Foundation
import Combine

/// iOS does not expose a general-purpose public ambient-light sensor API
/// to ordinary third-party apps. This type deliberately does not pretend
/// that a lux value is being read from hardware.
@MainActor
final class AmbientLightMonitor: ObservableObject {
    @Published private(set) var hardwareReadingAvailable = false
    @Published var previewLux: Double = 80

    var status: String {
        hardwareReadingAvailable ? "已连接环境光数据源" : "无公开通用接口；当前为手动模拟值"
    }
}

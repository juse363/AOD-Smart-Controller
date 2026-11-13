import Foundation
import Darwin
import Combine
import UIKit

/// Read-only capability inventory. It avoids private MobileGestalt writes
/// and never claims that a capability flag changes display hardware.
@MainActor
final class SystemCapabilityInspector: ObservableObject {
    @Published private(set) var deviceIdentifier: String
    @Published private(set) var systemVersion: String
    @Published private(set) var appState: String
    @Published private(set) var summary: String

    init() {
        var info = utsname()
        uname(&info)
        let machineCapacity = MemoryLayout.size(ofValue: info.machine)
        let machine = withUnsafePointer(to: &info.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: machineCapacity) {
                String(cString: $0)
            }
        }
        deviceIdentifier = machine
        systemVersion = UIDevice.current.systemVersion
        appState = Self.describe(UIApplication.shared.applicationState)
        summary = machine == "iPhone14,3"
            ? "已识别 iPhone 13 Pro Max；设备不具备 iPhone 14 Pro 的原生 1Hz AOD 显示硬件。"
            : "已读取设备标识。硬件能力不能通过软件标记升级。"
    }

    func refreshAppState() {
        appState = Self.describe(UIApplication.shared.applicationState)
    }

    private static func describe(_ state: UIApplication.State) -> String {
        switch state {
        case .active: return "前台运行"
        case .inactive: return "暂时非活动"
        case .background: return "后台运行（系统可能挂起）"
        @unknown default: return "未知"
        }
    }

    var aodControlStatus: String {
        "不可用：普通 IPA 没有公开的 SpringBoard 原生 AOD 开关接口"
    }
}

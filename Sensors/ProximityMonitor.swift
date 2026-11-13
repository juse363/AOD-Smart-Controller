import Foundation
import Combine
import UIKit

@MainActor
final class ProximityMonitor: ObservableObject {
    @Published private(set) var isSupported = false
    @Published private(set) var isCovered = false
    @Published private(set) var status = "尚未启动"

    private var proximityObserver: NSObjectProtocol?

    func start() {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        isSupported = device.isProximityMonitoringEnabled

        guard isSupported else {
            status = "当前环境无法启用接近监测"
            return
        }

        isCovered = device.proximityState
        status = "已启用；请在前台遮挡刘海附近测试"

        guard proximityObserver == nil else { return }
        proximityObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.proximityStateDidChangeNotification,
            object: device,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isCovered = UIDevice.current.proximityState
            }
        }
    }

    func stop() {
        if let proximityObserver {
            NotificationCenter.default.removeObserver(proximityObserver)
            self.proximityObserver = nil
        }
        UIDevice.current.isProximityMonitoringEnabled = false
    }
}

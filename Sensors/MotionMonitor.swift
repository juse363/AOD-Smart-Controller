import Foundation
import Combine
import CoreMotion

@MainActor
final class MotionMonitor: ObservableObject {
    @Published private(set) var isAvailable = false
    @Published private(set) var isFaceDown = false
    @Published private(set) var description = "等待姿态数据"

    private let manager = CMMotionManager()

    func start() {
        guard manager.isDeviceMotionAvailable else {
            description = "设备运动数据不可用"
            return
        }

        isAvailable = true
        manager.deviceMotionUpdateInterval = 0.25
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self, let motion, error == nil else { return }

            // Gravity z near -1 means the screen is generally facing downward.
            let z = motion.gravity.z
            let faceDown = z < -0.82
            Task { @MainActor in
                self.isFaceDown = faceDown
                self.description = faceDown ? "屏幕朝下" : "未检测到屏幕朝下"
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

import Foundation
import Combine

@MainActor
final class AODDecisionEngine: ObservableObject {
    @Published private(set) var state: AODState = .unknown
    @Published private(set) var reason = "等待输入"
    @Published var darkThresholdLux: Double = 5
    @Published var previewLux: Double = 80
    @Published var useSimulatedLux = true

    private var proximityCovered = false
    private var faceDown = false
    private var sensorsReady = false

    func update(
        proximityCovered: Bool? = nil,
        faceDown: Bool? = nil,
        sensorsReady: Bool? = nil
    ) {
        if let proximityCovered { self.proximityCovered = proximityCovered }
        if let faceDown { self.faceDown = faceDown }
        if let sensorsReady { self.sensorsReady = sensorsReady }
        recalculate()
    }

    func setPreviewLux(_ lux: Double) {
        previewLux = lux
        recalculate()
    }

    func recalculate() {
        guard sensorsReady else {
            state = .unknown
            reason = "接近与姿态传感器尚未全部就绪"
            return
        }

        if proximityCovered {
            state = .pocket
            reason = "接近传感器报告遮挡"
        } else if faceDown {
            state = .sleep
            reason = "运动传感器检测到屏幕朝下"
        } else if useSimulatedLux && previewLux <= darkThresholdLux {
            state = .dim
            reason = "模拟环境光 \(Int(previewLux)) lx ≤ 阈值 \(Int(darkThresholdLux)) lx"
        } else {
            state = .active
            reason = useSimulatedLux ? "未满足熄屏条件" : "环境光硬件数据不可用"
        }
    }
}

import Foundation

enum AODState: String {
    case active = "正常显示条件"
    case dim = "暗环境条件"
    case pocket = "口袋遮挡条件"
    case sleep = "建议熄屏"
    case unknown = "等待传感器数据"

    var explanation: String {
        switch self {
        case .active: return "未检测到遮挡，环境光数据尚未确认"
        case .dim: return "模拟或已验证的环境光低于阈值"
        case .pocket: return "接近传感器检测到遮挡"
        case .sleep: return "满足预设的熄屏判断条件"
        case .unknown: return "正在等待可用的传感器数据"
        }
    }
}

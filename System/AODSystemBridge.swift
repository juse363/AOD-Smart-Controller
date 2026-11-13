import Foundation

enum AODSystemBridgeResult {
    case unsupported(String)
}

/// Safety boundary between the decision engine and iOS.
/// No private selector, MobileGestalt mutation, or SpringBoard write is attempted.
struct AODSystemBridge {
    func requestDisplayState(for decision: AODState) -> AODSystemBridgeResult {
        .unsupported("已生成“\(decision.rawValue)”建议；当前 iOS 不向普通第三方 App 公开原生 AOD 控制接口。")
    }
}

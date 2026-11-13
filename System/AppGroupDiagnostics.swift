import Foundation
import Combine

/// Verifies only the app's own App Group container.
/// This does not access or modify MobileGestalt, SpringBoard, or system files.
@MainActor
final class AppGroupDiagnostics: ObservableObject {
    // Candidate identifier for this app. It must exactly match an App Group
    // entitlement granted to the signed app; declaring this string alone grants nothing.
    let groupIdentifier = "group.com.aodsmart.controller"

    @Published private(set) var status = "尚未检测"
    @Published private(set) var detail = "点击检测后，将验证当前签名是否允许访问该共享容器。"

    func runCheck() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) else {
            status = "不可访问"
            detail = "系统未向当前签名的 App 授予此 Group 容器。可能是尚未配置/注册 App Group，或 iLoader 签名时未保留相应 entitlement。"
            return
        }

        let probeURL = containerURL.appendingPathComponent(
            ".aodsmart-group-check-\(UUID().uuidString).tmp"
        )
        let payload = Data("AODSmartController App Group check".utf8)

        do {
            try payload.write(to: probeURL, options: .atomic)
            let readBack = try Data(contentsOf: probeURL)
            try FileManager.default.removeItem(at: probeURL)

            guard readBack == payload else {
                status = "读写校验失败"
                detail = "容器可访问，但临时文件内容校验不一致。"
                return
            }

            status = "容器读写成功"
            detail = "当前签名可访问指定 App Group，并通过临时文件读写与清理测试。仍需单独验证其他系统能力。"
        } catch {
            try? FileManager.default.removeItem(at: probeURL)
            status = "容器存在但读写失败"
            detail = "错误：\(error.localizedDescription)"
        }
    }
}

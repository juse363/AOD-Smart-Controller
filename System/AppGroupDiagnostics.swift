import Foundation
import Combine

/// Verifies only the app's own App Group container.
/// This does not access or modify MobileGestalt, SpringBoard, or system files.
@MainActor
final class AppGroupDiagnostics: ObservableObject {
    // This is only a candidate ID. The signed app must be granted this exact group.
    let groupIdentifier = "group.com.aodsmart.controller"

    @Published private(set) var status = "尚未检测"
    @Published private(set) var detail = "点击检测后，将分别检查容器授权和临时文件读写。"
    @Published private(set) var containerStatus = "尚未检查"
    @Published private(set) var fileTestStatus = "尚未执行"
    @Published private(set) var isChecking = false
    @Published private(set) var lastChecked = "暂无"

    func runCheck() {
        guard !isChecking else { return }

        isChecking = true
        status = "正在检测…"
        detail = "检测按钮已触发，正在向 iOS 请求 App Group 容器。"
        containerStatus = "检查中…"
        fileTestStatus = "等待容器检查"
        
        // Yield once so SwiftUI can render the visible "checking" state.
        Task { @MainActor in
            await Task.yield()
            performCheck()
            lastChecked = Date.now.formatted(date: .omitted, time: .standard)
            isChecking = false
        }
    }

    private func performCheck() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) else {
            status = "容器不可访问"
            containerStatus = "iOS 未提供容器 URL"
            fileTestStatus = "未执行（容器不存在或未授权）"
            detail = "按钮已正常触发。当前签名没有获得此 Group ID 的容器访问权，或签名中使用的 Group ID 与本程序候选值不同。单凭此结果不能判断 iLoader 是否签名成功。"
            return
        }

        containerStatus = "已取得容器 URL"
        let probeURL = containerURL.appendingPathComponent(
            ".aodsmart-group-check-\(UUID().uuidString).tmp"
        )
        let payload = Data("AODSmartController App Group check".utf8)
        var createdProbe = false

        do {
            try payload.write(to: probeURL, options: .atomic)
            createdProbe = true
            let readBack = try Data(contentsOf: probeURL)
            guard readBack == payload else {
                fileTestStatus = "内容校验不一致"
                status = "读写校验失败"
                detail = "容器存在且允许写入/读取操作，但读回内容与写入内容不一致。"
                try? FileManager.default.removeItem(at: probeURL)
                return
            }

            try FileManager.default.removeItem(at: probeURL)
            createdProbe = false
            fileTestStatus = "写入、读取、删除均成功"
            status = "检测通过"
            detail = "当前签名可访问该 App Group 容器，临时文件读写和清理均成功。这不代表获得 MobileGestalt 或 SpringBoard 权限。"
        } catch {
            if createdProbe {
                try? FileManager.default.removeItem(at: probeURL)
            }
            fileTestStatus = "文件操作失败"
            status = "容器存在但读写失败"
            detail = "容器 URL 已取得，但临时文件测试失败：\(error.localizedDescription)"
        }
    }
}

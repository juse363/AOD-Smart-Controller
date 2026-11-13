import Foundation
import Combine

/// Diagnoses the App Groups actually embedded in this app's code signature.
/// It does not create entitlements or access MobileGestalt / SpringBoard.
@MainActor
final class AppGroupDiagnostics: ObservableObject {
    @Published private(set) var status = "尚未检测"
    @Published private(set) var detail = "点击检测后，将读取当前安装包签名中的 App Groups，并逐一验证容器。"
    @Published private(set) var entitlementStatus = "尚未读取"
    @Published private(set) var groupIdentifiers: [String] = []
    @Published private(set) var containerStatus = "尚未检查"
    @Published private(set) var fileTestStatus = "尚未执行"
    @Published private(set) var isChecking = false
    @Published private(set) var lastChecked = "暂无"

    var groupIdentifiersText: String {
        groupIdentifiers.isEmpty ? "未发现可用 Group ID" : groupIdentifiers.joined(separator: "\n")
    }

    func runCheck() {
        guard !isChecking else { return }
        isChecking = true
        status = "正在检测…"
        detail = "正在读取当前 App 的代码签名，并检查其中声明的 App Groups。"
        entitlementStatus = "读取中…"
        containerStatus = "等待签名读取"
        fileTestStatus = "等待容器检查"

        Task { @MainActor in
            await Task.yield()
            performCheck()
            lastChecked = Date.now.formatted(date: .omitted, time: .standard)
            isChecking = false
        }
    }

    private func performCheck() {
        let groups: [String]
        do {
            groups = try SignedEntitlementsReader.readAppGroups()
            groupIdentifiers = groups
            entitlementStatus = groups.isEmpty ? "签名中未声明 App Groups" : "已读取 \(groups.count) 个 Group"
        } catch {
            groupIdentifiers = []
            entitlementStatus = "无法读取签名权限"
            containerStatus = "未检查"
            fileTestStatus = "未执行（签名读取失败）"
            status = "权限诊断不完整"
            detail = "读取当前 App 的签名信息失败：\(error.localizedDescription)。这不代表签名一定无效；当前构建可能未包含可解析的 XML Entitlements。"
            return
        }

        guard !groups.isEmpty else {
            containerStatus = "签名中没有 App Groups"
            fileTestStatus = "未执行（没有授权的 Group ID）"
            status = "未发现 App Group"
            detail = "当前安装包的可执行文件签名中没有声明 com.apple.security.application-groups。仅在工程里写入一个 Group ID 并不能授予权限；签名和 provisioning profile 必须允许对应 entitlement。"
            return
        }

        var accessible: [(String, URL)] = []
        for group in groups {
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) {
                accessible.append((group, url))
            }
        }

        guard !accessible.isEmpty else {
            containerStatus = "已声明，但 iOS 未提供容器"
            fileTestStatus = "未执行（没有可访问容器）"
            status = "容器不可访问"
            detail = "签名声明了 \(groups.count) 个 App Group，但系统没有为其中任何一个返回容器 URL。请检查重签后的 entitlement 与 provisioning profile 是否匹配。"
            return
        }

        containerStatus = "已取得 \(accessible.count)/\(groups.count) 个容器"
        var passed: [String] = []
        var failures: [String] = []

        for (group, containerURL) in accessible {
            let probeURL = containerURL.appendingPathComponent(".nexus-group-check-\(UUID().uuidString).tmp")
            let payload = Data("NEXUS App Group diagnostic".utf8)
            var created = false
            do {
                try payload.write(to: probeURL, options: .atomic)
                created = true
                let readBack = try Data(contentsOf: probeURL)
                guard readBack == payload else {
                    throw CocoaError(.fileReadCorruptFile)
                }
                try FileManager.default.removeItem(at: probeURL)
                created = false
                passed.append(group)
            } catch {
                if created { try? FileManager.default.removeItem(at: probeURL) }
                failures.append("\(group): \(error.localizedDescription)")
            }
        }

        if failures.isEmpty {
            fileTestStatus = "全部通过（\(passed.count) 个容器）"
            status = "容器与文件读写正常"
            detail = "已从实际签名读取 Group ID，并对每个可访问容器完成临时文件写入、读取、内容校验和删除。该结果只证明 App Group 文件访问，不代表拥有 MobileGestalt 或 SpringBoard 权限。"
        } else {
            fileTestStatus = "通过 \(passed.count) 个，失败 \(failures.count) 个"
            status = passed.isEmpty ? "文件读写失败" : "部分容器可用"
            detail = (passed.isEmpty ? "没有容器通过文件读写测试。" : "部分容器测试成功。") + "失败详情：" + failures.joined(separator: "；")
        }
    }
}

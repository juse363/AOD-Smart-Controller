# AOD Smart Controller 0.2.0 (development)

0.2.0 adds read-only device capability diagnostics and an explicit system AOD integration boundary. See README-0.2.0.md for details.

Previous prototype notes follow.

# AOD Smart Controller 0.1.0

中文界面的 iOS 传感器与 AOD 判断算法原型，目标设备为 iPhone 13 Pro Max。

## 当前实现

- 接近传感器状态监测（`UIDevice`）
- 设备姿态监测（`CoreMotion`）
- AOD 决策状态机
- 可调环境光阈值与模拟 lux 输入
- 中文 SwiftUI 界面
- GitHub Actions macOS 云端构建工作流

## 明确限制

1. 普通第三方 iOS 应用没有公开通用的环境光传感器 lux 读取 API；当前环境光输入是模拟值。
2. 普通 IPA 没有公开 API 可以关闭或控制 SpringBoard 的原生 AOD。
3. iOS 不保证普通应用锁屏或进入后台后持续执行传感器监听。
4. 该项目当前是诊断与算法原型，不是已实现的原生 AOD 移植工具。

## 在 Windows 11 上构建

> 当前工作流只生成未签名 IPA。它不是已验证可安装的成品；需由 AltStore/SideStore 等工具使用用户自己的 Apple ID 签名后安装。项目尚未在本环境中用 Xcode 真机 SDK 完成编译验证。

1. 将仓库推送到 GitHub。
2. 打开仓库的 Actions 页面。
3. 运行 `Build unsigned IPA` 工作流。
4. 下载 `AODSmartController-unsigned-ipa` artifact。
5. 使用 AltStore、SideStore 等工具按其当前要求签名安装。未签名 IPA 不能直接安装。

工作流使用 macOS GitHub-hosted runner、Xcode 与 XcodeGen。无需在 Windows 本机安装 Xcode。

## 本地项目生成

安装 XcodeGen 后执行：

```bash
xcodegen generate
```

然后使用 Xcode 打开生成的 `AODSmartController.xcodeproj`。
